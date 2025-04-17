`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module uart (input wire clk,
            input wire rst, //reset the uart
            input wire [7:0] din, //data input
            input wire [7:0] address, // address for baud, control, or buffer
            input wire w_en, //write enable (writing to the buffer)
            input wire r_en, //read enable (able to read from the uart)
            output reg [7:0] dout, //data output (the data the uart outputs to the serial port monitor)
            input wire rx,         //read 
            output reg tx = 1     //transfer 
//            output wire bar
);
//assign bar = sample_enable;
    //***********************************************************************************
    // Might want an enable bit to switch from normal i/o operation to
    // uart mode.   (what is normal i/o? how is it different from uart mode?)
    //***********************************************************************************
    //
    //                                uart_control
    // *--------*--------*--------*--------*--------*--------*--------*--------*
    // |        |        |        |        |        |        | tx_emty| rx_full|
    // *--------*--------*--------*--------*--------*--------*--------*--------*
    //     7        6        5        4        3        2        1        0   
    // uart_control[7:2] are insignificant! can be anything because we are not using them!
    //***********************************************************************************

    // I think the equation is: baud_reg = F_CPU/(16*baud_rate) - 1 
    //For our case we are going to have baud_reg = (100 MHZ)/(16*9600) - 1
    reg [15:0] baud = 651; // (100_000_000)/(16*9600) - 1; //what is baud!! number of signal units per second


    //localparam UART_BAUD_ADDRESS = 0;   //BAUD_ADDRESS = 0
    localparam UART_CONTROL_ADDRESS = 8'd1; //UART_CONTROL_ADDRESS = 1;
    localparam UART_BUFFER_ADDRESS = 8'd2;  // UART_BUFFER_ADDRESS = 2;

    reg [7:0] uart_control = 8'b00000010; //what is this? oh! I see! We care about the 2 least significant bits. 
                                           //tx_empty = 1; and rx_full = 0; uart control ready to recieve data.
    reg [7:0] rx_buffer = 8'b0;          //rx_buffer holds the data to recieved
    reg [7:0] tx_buffer = 8'b0;         //tx_buffer holds the data to be transferred
    always @(posedge clk) begin
        if(rst) begin
            baud <=  651;   //number of bits per second! why is it necessary to set this to 0...
            dout <= 8'b0;  
            uart_control[7:2] <= 6'b0; //all the insignificant bits set to '0'.
            tx_buffer <= 8'b0; //we ain't transferring data
        end
        else begin
            case(address)
            UART_CONTROL_ADDRESS: begin
                if(w_en) begin
                    uart_control[7:2] <= din[7:2];   //insignificant
                end
                if(r_en) begin
                   dout <= uart_control; //set data output to uart control.
                end
            end
            UART_BUFFER_ADDRESS: begin
                if (w_en) begin
                    tx_buffer <= din; //transfer buffer = data input
                end
                if (r_en) begin
                    dout <= rx_buffer; //data output = reciever buffer (do we care about this?? and why?)
                end
            end
            default begin
                dout <= 0;    //if the address is not the expected, then we should set the dout to 0
                            //We only care about [dout]. But for our experiment we have our data in [din].  
            end
            endcase
        end
    end
    //***********************************************************************************
    //                                 Create sampling clock                            *
    //                       What is the purpose of the sampling clock?                 *
    //************************************************************************************
    
    reg [15:0] prescaler = 16'b0; //mhh. what is prescaling. what is it significance in this experiment?
                                //divide the frequency by some integer value to enable the data to be handled by a counter which\
                                //cannot handle the original frequency. 
    reg sample_enable = 1'b0;   // enable the sampling of frequency??
    always @(posedge clk) begin
        if(rst) begin
            prescaler <= 16'b0;
            sample_enable <= 0;
        end
        else begin
            if(prescaler == baud) begin
                prescaler <= 0;             //why should the prescaler be equivalent to baud?? i thought baud was the signal rate..clearly it is not!!!
                sample_enable <= 1;        
            end
            else begin
                prescaler <= prescaler + 1;  //incremementing the prescaler to 
                sample_enable <= 0;
            end
        end
    end
    //***********************************************************************************
    // Synchronizers
    reg s0 = 1'b1;
    reg s1 = 1'b1;
    always @(posedge clk) begin
        if(rst) begin
            s0 <= 1'b1;
            s1 <= 1'b1;
        end
        else if(sample_enable) begin
            s0 <= rx;     //sample enable ? rx is  reciever
            s1 <= s0;   // s1 = s0 = reciever
        end
    end
    wire rx_clean = s1 && s0; // make sure the value is consistent; 
    //***********************************************************************************
    // Rx State Machine  
    //do we want any thing to do with recieving yes. we  are recieving from artix. 
    reg [2:0] rx_state = 3'b0; //what is this? what is the rx state? is it like ready to recieve data from artix?
    reg [7:0] rx_data = 8'b0; // the data from artix 7. 
    reg [3:0] rx_count = 4'b0;  //counter for recieving
    reg [3:0] rx_delay = 4'b0; //delay when recieving!!
     //
    //                                uart_control
    // *--------*--------*--------*--------*--------*--------*--------*--------*
    // |        |        |        |        |        |        | tx_emty| rx_full|
    // *--------*--------*--------*--------*--------*--------*--------*--------*
    //     7        6        5        4        3        2        1        0   
    always @(posedge clk) begin
        if(rst) begin
            rx_state <= 3'b0;
            rx_data <= 8'b0;
            rx_count <= 4'b0;
            rx_delay <= 4'b0;
            rx_buffer <= 8'b0;
            uart_control[0] <= 1'b0;
        end
        else begin
            if(sample_enable) begin
                case(rx_state)
                3'b000: begin                       // Look for start bit
                                                    //where are we looking for start bit? where are we getting the data from
                    if(rx_clean == 1'b0) begin     //this is 0 when s0 and s1 are 0 or different. why are we want it to be that way??
                        rx_state <= 3'b001;      
                    end
                end
                3'b001: begin                       // Sample first data bit
                    if(rx_delay == 4'b0111) begin   //delay for 7 cycles
                        rx_data <= {rx_data[6:0],rx_clean}; // what is this doing? concatenating the two values  to have rx_data[7:0]. the least significant bit 
                                                            //should be 0 because we come to state 1 if when rx_clean = 0. Now I wonder!!
                                                            //rx_data will be xxxxxxx0. This is not accurate. What is going on here?? 
                                                            //mhh. oh i see! we have 128 ascii characters and the 0 is a stop b it perhaps. 
                        rx_delay <= 4'b0;   
                        rx_state <= 3'b010;
                    end
                    else begin
                        rx_delay <= rx_delay + 1;
                    end
                end
                3'b010: begin                       // Sample the other data bits 
                    if(rx_delay == 4'b1111) begin //we are delaying for 16 cycles. 
                        rx_data <= {rx_clean,rx_data[7:1]}; //this is what I was expecting 
                        rx_delay <= 4'b0;
                        rx_count <= rx_count + 1;
                        if(rx_count == 4'b0111) begin
                            rx_count <= 4'b0;
                            rx_state <= 3'b011;
                        end
                    end
                    else begin
                        rx_delay <= rx_delay + 1;
                    end
                end
                3'b011: begin                       // Sample stop bit
                    if(rx_delay == 4'b1111) begin
                        if(rx_clean == 1) begin
                            rx_delay <= 0;
                            rx_buffer <= rx_data;
                            uart_control[0] <= 1'b1;
                            rx_state <= 3'b000;
                        end
                        else begin
                            rx_delay <= 0;
                            rx_state <= 3'b100;
                        end
                    end
                    else begin
                        rx_delay <= rx_delay + 1;
                    end
                end
                3'b100: begin                       // Frame error, wait till rx_clean is high,
                    if(rx_clean) begin              // then go to rx_state 0
                        rx_state <= 3'b000;
                    end
                end
                default begin
                    rx_state <= 3'b000;
                end
                endcase
            end
            if(address == UART_BUFFER_ADDRESS && r_en) begin
                uart_control[0] <= 0;
            end
            else if(sample_enable && rx_state == 3'b011 && rx_delay == 4'b1111 && rx_clean == 1) begin
                uart_control[0] <= 1;
            end
        end
    end 
    //***********************************************************************************
    //                                Tx State Machine
    //***********************************************************************************
    reg [1:0] tx_state = 2'b0;
    reg [7:0] tx_data = 8'd255;
    reg [3:0] tx_count = 4'b0;
    reg [3:0] tx_delay = 4'b0;

    always @(posedge clk) begin
        if(rst) begin
            tx <= 1;
            tx_state <= 2'b0;
            tx_data <= 8'b0;
            tx_count <= 4'b0;
            tx_delay <= 4'b0;
            uart_control[1] <= 1'b1;
        end
        else begin
            if(sample_enable) begin
                case(tx_state)
                2'b00: begin                        // Wait for tx buffer to be full (not empty) before starting
                    if(uart_control[1] == 0) begin
                        tx_data <= tx_buffer;
                        tx_state <= 2'b01;
                        tx_count <= 4'b1;
                        tx <= 0;                    // Start bit
                    end
                end
                2'b01: begin
                    if(tx_delay == 4'b1111) begin   // Finish start bit, send data bits, begin stop bit
                        tx_delay <= 0;
                        tx_count <= tx_count + 1;
                        if(tx_count == 4'b1001) begin
                            tx <= 1;                // Stop bit
                            tx_state <= 2'b10;
                        end
                        else begin
                            tx <= tx_data[0];       // Data bit
                            tx_data <= {1'b0,tx_data[7:1]};
                        end
          
                    end
                    else begin
                        tx_delay <= tx_delay + 1;
                    end
                end
                2'b10: begin                        // Finish stop bit
                    if(tx_delay == 4'b1111) begin
                        tx_delay <= 0;
                        tx_count <= 0;
                        tx_state <= 2'b00;
                    end
                    else begin
                        tx_delay <= tx_delay + 1;
                    end
                end
                endcase
            end
            if(address == UART_BUFFER_ADDRESS && w_en) begin
                uart_control[1] <= 0;
            end
            else if(sample_enable && tx_state == 2'b0 && uart_control[1] == 0) begin
                uart_control[1] <= 1;
            end
        end
    end
    //***********************************************************************************
endmodule
