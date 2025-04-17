`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Plain Verilog-2001 implementation of Smith-Waterman with affine-gap penalties
//////////////////////////////////////////////////////////////////////////////////
module smith_waterman_affine_refined #(
    parameter MAX_LEN1          = 64,
    parameter MAX_LEN2          = 64,
    parameter DATA_WIDTH        = 8,
    parameter SCORE_WIDTH       = 16,
    parameter signed MATCH_SCORE        =  3,
    parameter signed MISMATCH_PENALTY   = -2,
    parameter signed GAP_OPEN_PENALTY   = -10,
    parameter signed GAP_EXTEND_PENALTY = -1
) (
    input  clk,
    input  rst_n,
    input  start,
    input  [DATA_WIDTH*MAX_LEN1-1:0] seq1_flat,
    input  [$clog2(MAX_LEN1+1)-1:0] len1,  // if your tool supports $clog2
    input  [DATA_WIDTH*MAX_LEN2-1:0] seq2_flat,
    input  [$clog2(MAX_LEN2+1)-1:0] len2,
    output reg busy,
    output reg done,
    output reg valid_out,
    output [SCORE_WIDTH-1:0] max_score_out,
    output [$clog2(MAX_LEN1+1)-1:0] max_pos_i_out,
    output [$clog2(MAX_LEN2+1)-1:0] max_pos_j_out,
    output reg [7:0] led_max_score
);

    // Function for clog2 if not built-in
    function integer clog2;
        input integer value;
        integer i;
        begin
            clog2 = 0;
            for (i = value-1; i > 0; i = i >> 1)
                clog2 = clog2 + 1;
        end
    endfunction

    // Derived sizes
    localparam ROWS     = MAX_LEN1 + 1;
    localparam COLS     = MAX_LEN2 + 1;
    localparam DEPTH    = ROWS * COLS;
    localparam signed MIN_SCORE    = -(1 << (SCORE_WIDTH-1));
    localparam signed GAP_AFF_PEN  = GAP_OPEN_PENALTY + GAP_EXTEND_PENALTY;
    localparam signed SAT_THRES    = 8'd255;

    // FSM state encoding
    localparam IDLE = 2'd0, INIT = 2'd1, CALC = 2'd2, FIN = 2'd3;
    reg [1:0] state, next_state;

    // Indices and trackers
    reg [clog2(MAX_LEN1+1)-1:0] i_reg, j_reg;
    reg [clog2(MAX_LEN1+1)-1:0] i_next, j_next;
    reg signed [SCORE_WIDTH-1:0] max_score, max_score_next;
    reg [clog2(MAX_LEN1+1)-1:0] max_i, max_i_next;
    reg [clog2(MAX_LEN2+1)-1:0] max_j, max_j_next;

    // Sequence buffers (flattened)
    reg [DATA_WIDTH-1:0] seq1_buf [0:MAX_LEN1-1];
    reg [DATA_WIDTH-1:0] seq2_buf [0:MAX_LEN2-1];
    reg [clog2(MAX_LEN1+1)-1:0] len1_buf;
    reg [clog2(MAX_LEN2+1)-1:0] len2_buf;
    reg start_prev;

    // DP storage (flattened)
    reg signed [SCORE_WIDTH-1:0] H_mem [0:DEPTH-1];
    reg signed [SCORE_WIDTH-1:0] E_mem [0:DEPTH-1];
    reg signed [SCORE_WIDTH-1:0] F_mem [0:DEPTH-1];

    // Combinational temporaries
    reg signed [SCORE_WIDTH-1:0] mval, dscore;
    reg signed [SCORE_WIDTH-1:0] eopen, eext, enxt;
    reg signed [SCORE_WIDTH-1:0] fopen, fext, fnxt;
    reg signed [SCORE_WIDTH-1:0] uncl, hcand;

    wire start_pulse = start & ~start_prev;

    integer r, c, idx;

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            i_reg        <= 0;
            j_reg        <= 0;
            max_score    <= MIN_SCORE;
            max_i        <= 0;
            max_j        <= 0;
            busy         <= 0;
            done         <= 0;
            valid_out    <= 0;
            led_max_score<= 0;
            start_prev   <= 0;
            // Initialize DP arrays
            for (idx = 0; idx < DEPTH; idx = idx + 1) begin
                H_mem[idx] <= 0;
                E_mem[idx] <= MIN_SCORE;
                F_mem[idx] <= MIN_SCORE;
            end
        end else begin
            state        <= next_state;
            i_reg        <= i_next;
            j_reg        <= j_next;
            max_score    <= max_score_next;
            max_i        <= max_i_next;
            max_j        <= max_j_next;
            busy         <= (next_state != IDLE);
            done         <= (state == FIN);
            valid_out    <= (state == FIN);
            start_prev   <= start;

            if (start_pulse) begin
                len1_buf <= len1;
                len2_buf <= len2;
                // Unflatten inputs
                for (r = 0; r < MAX_LEN1; r = r + 1)
                    seq1_buf[r] <= seq1_flat[r*DATA_WIDTH +: DATA_WIDTH];
                for (r = 0; r < MAX_LEN2; r = r + 1)
                    seq2_buf[r] <= seq2_flat[r*DATA_WIDTH +: DATA_WIDTH];
                // Initialize boundaries
                for (r = 0; r < ROWS; r = r + 1) begin
                    idx = r*COLS + 0;
                    H_mem[idx] <= 0;
                    E_mem[idx] <= MIN_SCORE;
                    F_mem[idx] <= MIN_SCORE;
                end
                for (c = 0; c < COLS; c = c + 1) begin
                    idx = 0*COLS + c;
                    H_mem[idx] <= 0;
                    E_mem[idx] <= MIN_SCORE;
                    F_mem[idx] <= MIN_SCORE;
                end
                // Reset trackers
                max_score_next <= MIN_SCORE;
                max_i_next     <= 0;
                max_j_next     <= 0;
            end

            // Write DP cell result
            if (state == CALC && i_reg > 0 && j_reg > 0) begin
                idx = i_reg*COLS + j_reg;
                H_mem[idx] <= hcand;
                E_mem[idx] <= enxt;
                F_mem[idx] <= fnxt;
            end

            // LED saturation
            if (next_state == FIN) begin
                if (max_score <= 0)
                    led_max_score <= 0;
                else if (max_score > SAT_THRES)
                    led_max_score <= 8'hFF;
                else
                    led_max_score <= max_score[7:0];
            end
        end
    end

    // Combinational logic
    always @(*) begin
        // Default next-state values
        next_state      = state;
        i_next          = i_reg;
        j_next          = j_reg;
        max_score_next  = max_score;
        max_i_next      = max_i;
        max_j_next      = max_j;

        // Compute match/mismatch
        if (i_reg != 0 && j_reg != 0 && seq1_buf[i_reg-1] == seq2_buf[j_reg-1])
            mval = MATCH_SCORE;
        else
            mval = MISMATCH_PENALTY;
        // Compute diagonal score
        if (i_reg != 0 && j_reg != 0)
            dscore = H_mem[(i_reg-1)*COLS + (j_reg-1)] + mval;
        else
            dscore = 0;
        // Compute E (gap in seq1)
        if (j_reg != 0) begin
            eopen = H_mem[i_reg*COLS + (j_reg-1)] + GAP_AFF_PEN;
            eext  = E_mem[i_reg*COLS + (j_reg-1)] + GAP_EXTEND_PENALTY;
        end else begin
            eopen = MIN_SCORE;
            eext  = MIN_SCORE;
        end
        enxt = (eopen > eext) ? eopen : eext;
        // Compute F (gap in seq2)
        if (i_reg != 0) begin
            fopen = H_mem[(i_reg-1)*COLS + j_reg] + GAP_AFF_PEN;
            fext  = F_mem[(i_reg-1)*COLS + j_reg] + GAP_EXTEND_PENALTY;
        end else begin
            fopen = MIN_SCORE;
            fext  = MIN_SCORE;
        end
        fnxt = (fopen > fext) ? fopen : fext;
        // Compute H
        uncl  = (dscore > enxt) ? dscore : enxt;
        uncl  = (fnxt > uncl)   ? fnxt  : uncl;
        hcand = (uncl > 0)       ? uncl  : 0;

        // FSM transitions and trackers
        case (state)
            IDLE: if (start_pulse)
                      next_state = INIT;
            INIT: begin
                next_state     = CALC;
                i_next         = 1;
                j_next         = 1;
            end
            CALC: begin
                if (hcand > max_score) begin
                    max_score_next = hcand;
                    max_i_next     = i_reg;
                    max_j_next     = j_reg;
                end
                if (j_reg < len2_buf)
                    j_next = j_reg + 1;
                else if (i_reg < len1_buf) begin
                    i_next = i_reg + 1;
                    j_next = 1;
                end else
                    next_state = FIN;
            end
            FIN: next_state = IDLE;
        endcase
    end

    // Outputs
    assign max_score_out = (max_score <= 0 && valid_out) ? 0 : max_score;
    assign max_pos_i_out = max_i;
    assign max_pos_j_out = max_j;

endmodule
