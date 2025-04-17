`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2023 07:50:52 PM
// Design Name: 
// Module Name: CUT_4
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
//////////////////////////////////////////////////////////////////////////////////


module CUT_1 (
    input wire data_in,
    input wire normal_clk,
    input wire fast_clk, 
    input wire clear_diff,
    output reg diff = 0);

            (* DONT_TOUCH = "yes" *) wire inv1;
            (* DONT_TOUCH = "yes" *) wire inv2;
            (* DONT_TOUCH = "yes" *) wire inv3;
            (* DONT_TOUCH = "yes" *) wire inv4;
            wire sig;
            assign inv1 = ~data_in;
            assign inv2 = ~inv1;
            assign inv3 = ~inv2;
            assign inv4= ~inv3;
            
            
          assign sig = inv1;
            
          reg normal = 0;
          reg fast = 0; 
          
          
          always @(posedge normal_clk) begin
            normal <= sig;
          end 
          
          always @(posedge fast_clk) begin
            fast <= sig;
           end 
           
           
           always @(posedge fast_clk) begin 
              if (clear_diff) begin 
                    diff <= 0;
                end else if (normal != fast) begin
                    diff <= 1;
              end
            end 
            
            
endmodule
