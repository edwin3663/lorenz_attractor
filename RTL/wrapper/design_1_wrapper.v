//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
//Date        : Sun Jan 26 14:00:41 2020
//Host        : Jupiter running 64-bit Ubuntu 18.04.3 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (BTNC,
    blue_out,
    green_out,
    horz_sync_out,
    red_out,
    sys_clock,
    vert_sync_out);
  input BTNC;
  output [3:0]blue_out;
  output [3:0]green_out;
  output horz_sync_out;
  output [3:0]red_out;
  input sys_clock;
  output vert_sync_out;

  wire BTNC;
  wire [3:0]blue_out;
  wire [3:0]green_out;
  wire horz_sync_out;
  wire [3:0]red_out;
  wire sys_clock;
  wire vert_sync_out;

  design_1 design_1_i
       (.BTNC(BTNC),
        .blue_out(blue_out),
        .green_out(green_out),
        .horz_sync_out(horz_sync_out),
        .red_out(red_out),
        .sys_clock(sys_clock),
        .vert_sync_out(vert_sync_out));
endmodule
