`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2024 11:31:33 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Pennsylvania - IMPLEMENTATION OF COMPUTATION
// Engineer: NHLANHLA MAVUSO
// 
// Create Date: 09/02/2023 07:50:52 PM
// Design Name: ddfl (difference detector with first fail latch)
// Module Name: top
// Project Name: Adaptive Timing Repair
// Target Devices: xc7a200t
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
           input wire clk,
           output wire [7:0] led, 
           output wire tx
           );
           
           localparam integer MAX_LEN1    = 64;
           localparam integer MAX_LEN2    = 64;
           localparam integer DATA_WIDTH  = 8;
           localparam integer SCORE_WIDTH = 16;
           localparam integer LEN_W1 = 7;
           localparam integer LEN_W2 = 7;
           
           wire normal_clk;
           wire fast_clk;
           wire locked;
           wire psdone;
           reg psen = 0;
           reg psincdec = 1'b0;
           reg reset = 1'b0;
           wire sig;
           wire diff;
           reg clear_diff = 0;
           wire data;
           
           reg rst = 0;
           reg [7:0] din;
           reg [7:0] address; 
           reg w_en = 1;
           reg r_en = 0; 
           wire [7:0] dout;
           
           reg [31:0] cycles = 0;
           
          
          clockgen clockgen_i
           (.clk_in1(clk),
            .clk_out1(normal_clk),
            .clk_out2(fast_clk),
            .locked(locked),
            .psdone(psdone),
            .psen(psen),
            .psincdec(psincdec),
            .reset(reset));
            
            uart uart_i (
                .clk(normal_clk),
                .rst(rst),
                .din(din),
                .address(address),
                .w_en(w_en),
                .r_en(r_en), 
                .dout(dout),
                .tx(tx));
                
             CUT_1 data_processing_1 (
                .data_in(data),
                .normal_clk(normal_clk),
                .fast_clk(fast_clk), 
                .clear_diff(clear_diff),
                .diff(diff));
                
              
               
                
            //*********************************************************//
            // ****************Finite State Machine*******************//
            //********************************************************//

            localparam PREP = 5'd0;
            localparam RUN = 5'd1;
            localparam INC = 5'd2;
            localparam DONE = 5'd3;
            localparam READ_CONTROL = 5'd4;
            localparam WRITE_CONTROL = 5'd5;
            localparam UART_SIGNAL_SELECT = 5'd6;
            localparam UART_DONE = 5'd7;
            
            
             // Example sequences "ACGT" vs "AGT"
            wire [DATA_WIDTH*MAX_LEN1-1:0] seq1_flat = str_to_flat("ACGT");
            wire [DATA_WIDTH*MAX_LEN2-1:0] seq2_flat = str_to_flat("AGT ");
            wire [LEN_W1-1:0] len1_buf = 4;  // actual length in symbols
            wire [LEN_W2-1:0] len2_buf = 3;

            // Core outputs
            wire                       sw_busy;
            wire                       sw_done;
            wire                       sw_valid;
            wire [SCORE_WIDTH-1:0]     sw_score;
            wire [LEN_W1-1:0]          sw_i;
            wire [LEN_W2-1:0]          sw_j;
            wire [7:0]                 sw_led;

 
             
          
             smith_waterman_affine_refined #(
                    .MAX_LEN1(64),
                    .MAX_LEN2(64),
                    .DATA_WIDTH(8),
                    .SCORE_WIDTH(16)
                ) sw_inst (
                    .clk            (normal_clk),           // from clockgen
                    .rst_n          (~reset),               // active-low reset
                    .start          (state == RUN),         // pulse to launch alignment
                    .seq1_flat      (seq1_flat),
                    .len1           (len1_buf),             // your actual length
                    .seq2_flat      (seq2_flat),
                    .len2           (len2_buf),
                    .busy           (sw_busy),
                    .done           (sw_done),
                    .valid_out      (sw_valid),
                    .max_score_out  (sw_score),
                    .max_pos_i_out  (sw_i),
                    .max_pos_j_out  (sw_j),
                    .led_max_score  (sw_led)
                               //BITS_SELECT
                               
                      );
            
            localparam UPPER = 1'd0;
            localparam LOWER = 1'd1;
            
            reg [1:0] signal_state = LOWER;
            
            reg [15:0] inc_count = 0;
            reg [7:0] state = PREP;
            reg [4:0] uart_state = 5'd0;
            
            reg [7:0] uart_din;
            
            assign led = inc_count[7:0];
            
            always @(posedge normal_clk) begin 
                if(reset) begin
                    psen <= 1'd0;
                    inc_count <= 16'd0;
                    cycles <= 32'd0;
                    state <= PREP;
                    psincdec <= 1'd0;
                end
                else begin
                    case(state)                            
                    PREP: begin                     // wait for pll to lock
                        if(locked) begin
                            state <= RUN;
                        end
                    end
                    RUN: begin                      // let the clocks run, then quit if diff, else change the phase
                        if(cycles == 2000000) begin
                            if (diff) begin 
                                uart_din = inc_count[7:0];
                                state = DONE;
                            end else begin
                                cycles <= 0;
                                inc_count <= inc_count + 16'd1;
                                psen <= 1'b1;
                                state <= INC;
                            end
                        end
                        else begin  
                            cycles <= cycles + 1;
                        end
                    end
                    INC: begin                      // change the phase and go back to run when finished
                        psen <= 1'b0;
                        if(psdone) begin
                            state <= RUN;
                        end
                    end
                    
                    DONE: begin 
                        case (uart_state) 
                        READ_CONTROL: begin 
                            w_en <= 0;
                            r_en <= 1;
                            address <= 1;
                            if (dout[1] == 1) begin
                                uart_state <= WRITE_CONTROL;
                            end
                        end
                        
                        WRITE_CONTROL: begin 
                            w_en <= 1;
                            r_en <= 0;
                            address <= 2;
                            din <= uart_din; //Number 
                            uart_state <= UART_SIGNAL_SELECT;  
                        end
                        
                        UART_SIGNAL_SELECT: begin
                        //Design a way to select a signal for the finite state state Machine of the UART. 
                        //UPPER BITS, LOWER BITS
                        //
                            case (signal_state)
                            
                            LOWER: begin
                                uart_din = inc_count[15:8];
                                uart_state = READ_CONTROL;
                                signal_state = UPPER; 
                            end
                            UPPER: begin
                              
                               uart_state = UART_DONE;
                            end
                        endcase
                        end 
                        
                        UART_DONE: begin 
                         w_en <= 0;
                         r_en <= 0;
                         reset <= 1;
                         clear_diff = 1;
                        end  
            endcase 
                    end
                   endcase
                end
            end
            //*******************************************************
            // Data Gen
            reg [24:0] counter = 0;
            always @(posedge normal_clk) begin
                if(reset) begin
                    counter <= 0;
                end
                else begin
                    counter <= counter + 1;
                end
            end
           
            //********************************************************//
            //****************Place Holder For LUT capture************//
            //********************************************************// 
            assign data = counter[0]^counter[1]^counter[3];
          

endmodule
                        
           
           
           
////////////////////////////////////////////////
