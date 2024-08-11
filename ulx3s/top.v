`default_nettype none
module top
(
  // Clock
  input         clk_25mhz,
  // Needed in order to turn off the wifi module
  output        wifi_en,
  // HDMI
  output [3:0]  gpdi_dp,
  output [3:0]  gpdi_dn,
  // Audio
  output [3:0]  audio_l,
  output [3:0]  audio_r,
  // Leds
  output [7:0]  led
);

  // Keep wifi off
  assign wifi_en = 1'b0;

  // ===============================================================
  // Clock generation
  // ===============================================================
  wire [3:0] clocks;
  ecp5pll
  #(
      .in_hz( 25*1000000),
    .out0_hz(125*1000000),
    .out1_hz( 25*1000000),
  )
  ecp5pll_inst
  (
    .clk_i(clk_25mhz),
    .clk_o(clocks)
  );

  wire clk_25x1 = clocks[1];
  wire clk_25x5 = clocks[0];

  // ===============================================================
  // Reset generation
  // ===============================================================
  reg [5:0] reset_cnt;
  wire rst_n = &reset_cnt;
  
  always @(posedge clk_25mhz) begin
    reset_cnt <= reset_cnt + !rst_n;
  end

  // ===============================================================
  // TinyTapeout design instance
  // ===============================================================

  // ULX3S has a 4 bit resistor DAC, but the TT design has a 1 bit PDM output.
  wire audio;
  assign audio_l = {4{audio}};
  assign audio_r = {4{audio}};

  wire [1:0] r_out;
  wire [1:0] g_out;
  wire [1:0] b_out;

  wire [7:0] vga_r = {r_out[1], r_out[0], 6'b000000};
  wire [7:0] vga_g = {g_out[1], g_out[0], 6'b000000};
  wire [7:0] vga_b = {b_out[1], b_out[0], 6'b000000};
  wire vga_hsync;
  wire vga_vsync;
  wire vga_de;

// module vgademo (
//     input clk48,
//     input rst_n,
//     output reg vsync,  // vsync
//     output reg hsync,  // hsync
//     output wire display_active,  // display_active
//     output reg [1:0] b_out, // Blue
//     output reg [1:0] g_out, // Green
//     output reg [1:0] r_out  // Red
// );

  vgademo vgademo_instance (
      .vsync          (vga_vsync),
      .hsync          (vga_hsync),
      .display_active (vga_de),
      .b_out          (b_out),
      .g_out          (g_out),
      .r_out          (r_out),
      .audio_out      (audio),
      .clk48          (clk_25x1), // clock
      .rst_n          (rst_n)     // not reset      
  );

  // ===============================================================
  // Convert VGA to HDMI
  // ===============================================================
  HDMI_out vga2dvid (
    .pixclk(clk_25x1),
    .pixclk_x5(clk_25x5),
    .red(vga_r),
    .green(vga_g),
    .blue(vga_b),
    .vde(vga_de),
    .hSync(vga_hsync),
    .vSync(vga_vsync),
    .gpdi_dp(gpdi_dp),
    .gpdi_dn(gpdi_dn)
  );

endmodule
