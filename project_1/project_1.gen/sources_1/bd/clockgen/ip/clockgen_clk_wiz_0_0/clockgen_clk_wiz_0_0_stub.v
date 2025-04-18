// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
// Date        : Thu Apr 17 00:08:25 2025
// Host        : eiffel-ubuntu running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/eiffel/adaptive_timing_repair/project_1/project_1.gen/sources_1/bd/clockgen/ip/clockgen_clk_wiz_0_0/clockgen_clk_wiz_0_0_stub.v
// Design      : clockgen_clk_wiz_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tsbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CORE_GENERATION_INFO = "clockgen_clk_wiz_0_0,clk_wiz_v6_0_15_0_0,{component_name=clockgen_clk_wiz_0_0,use_phase_alignment=false,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=true,use_inclk_switchover=false,use_dyn_reconfig=false,enable_axi=0,feedback_source=FDBK_AUTO,PRIMITIVE=MMCM,num_out_clk=2,clkin1_period=10.000,clkin2_period=10.000,use_power_down=false,use_reset=true,use_locked=true,use_inclk_stopped=false,feedback_type=SINGLE,CLOCK_MGR_TYPE=NA,manual_override=false}" *) 
module clockgen_clk_wiz_0_0(clk_out1, clk_out2, psclk, psen, psincdec, psdone, 
  reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="psen,psincdec,psdone,reset,locked,clk_in1" */
/* synthesis syn_force_seq_prim="clk_out1" */
/* synthesis syn_force_seq_prim="clk_out2" */
/* synthesis syn_force_seq_prim="psclk" */;
  output clk_out1 /* synthesis syn_isclock = 1 */;
  output clk_out2 /* synthesis syn_isclock = 1 */;
  input psclk /* synthesis syn_isclock = 1 */;
  input psen;
  input psincdec;
  output psdone;
  input reset;
  output locked;
  input clk_in1;
endmodule
