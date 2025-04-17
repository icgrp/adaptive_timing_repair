// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

(* BLOCK_STUB = "true" *)
module clockgen (
  psincdec,
  psen,
  reset,
  clk_in1,
  locked,
  psdone,
  clk_out2,
  clk_out1
);

  (* X_INTERFACE_IGNORE = "true" *)
  input psincdec;
  (* X_INTERFACE_IGNORE = "true" *)
  input psen;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET RST" *)
  (* X_INTERFACE_MODE = "slave RST.RESET" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
  input reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_IN1 CLK" *)
  (* X_INTERFACE_MODE = "slave CLK.CLK_IN1" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_IN1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN clockgen_clk_in1, INSERT_VIP 0" *)
  input clk_in1;
  (* X_INTERFACE_IGNORE = "true" *)
  output locked;
  (* X_INTERFACE_IGNORE = "true" *)
  output psdone;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_OUT2 CLK" *)
  (* X_INTERFACE_MODE = "master CLK.CLK_OUT2" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_OUT2, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN clockgen_clk_wiz_0_0_clk_out1, INSERT_VIP 0" *)
  output clk_out2;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_OUT1 CLK" *)
  (* X_INTERFACE_MODE = "master CLK.CLK_OUT1" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_OUT1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN clockgen_clk_wiz_0_0_clk_out1, INSERT_VIP 0" *)
  output clk_out1;

  // stub module has no contents

endmodule
