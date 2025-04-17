//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
//Date        : Thu Apr 17 00:15:14 2025
//Host        : eiffel-ubuntu running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target clockgen_wrapper.bd
//Design      : clockgen_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module clockgen_wrapper
   (clk_in1,
    clk_out1,
    clk_out2,
    locked,
    psdone,
    psen,
    psincdec,
    reset);
  input clk_in1;
  output clk_out1;
  output clk_out2;
  output locked;
  output psdone;
  input psen;
  input psincdec;
  input reset;

  wire clk_in1;
  wire clk_out1;
  wire clk_out2;
  wire locked;
  wire psdone;
  wire psen;
  wire psincdec;
  wire reset;

  clockgen clockgen_i
       (.clk_in1(clk_in1),
        .clk_out1(clk_out1),
        .clk_out2(clk_out2),
        .locked(locked),
        .psdone(psdone),
        .psen(psen),
        .psincdec(psincdec),
        .reset(reset));
endmodule
