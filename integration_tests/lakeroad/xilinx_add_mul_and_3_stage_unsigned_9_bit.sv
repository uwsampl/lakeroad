// RUN: racket $LAKEROAD_DIR/bin/main.rkt \
// RUN:  --verilog-module-filepath %s \
// RUN:  --architecture xilinx-ultrascale-plus \
// RUN:  --template dsp \
// RUN:  --out-format verilog \
// RUN:  --top-module-name test \
// RUN:  --verilog-module-out-signal out:9 \
// RUN:  --initiation-interval 3 \
// RUN:  --clock-name clk \
// RUN:  --module-name out \
// RUN:  --input-signal a:9 \
// RUN:  --input-signal b:9 \
// RUN:  --input-signal c:9 \
// RUN:  --input-signal d:9 \
// RUN: | FileCheck %s

module test (
    input [8:0] a,
    input [8:0] b,
    input [8:0] c,
    input [8:0] d,
    output [8:0] out,
    input clk
);

  logic [8:0] stage0;
  logic [8:0] stage1;
  logic [8:0] stage2;

  always @(posedge clk) begin
    stage0 <= ((d + a) * b) & c;
    stage1 <= stage0;
    stage2 <= stage1;
  end

  assign out = stage2;
endmodule

// CHECK: module out(a, b, c, clk, d, out);
// CHECK:   wire [47:0] P_0;
// CHECK:   input [8:0] a;
// CHECK:   wire [8:0] a;
// CHECK:   input [8:0] b;
// CHECK:   wire [8:0] b;
// CHECK:   input [8:0] c;
// CHECK:   wire [8:0] c;
// CHECK:   input clk;
// CHECK:   wire clk;
// CHECK:   input [8:0] d;
// CHECK:   wire [8:0] d;
// CHECK:   output [8:0] out;
// CHECK:   wire [8:0] out;
// CHECK:   DSP48E2 #(
// CHECK:     .ACASCREG(32'd0),
// CHECK:     .ADREG(32'd0),
// CHECK:     .ALUMODEREG(32'd1),
// CHECK:     .AMULTSEL("AD"),
// CHECK:     .AREG(32'd0),
// CHECK:     .AUTORESET_PATDET("NO_RESET"),
// CHECK:     .AUTORESET_PRIORITY("CEP"),
// CHECK:     .A_INPUT("DIRECT"),
// CHECK:     .BCASCREG(32'd0),
// CHECK:     .BMULTSEL("B"),
// CHECK:     .BREG(32'd0),
// CHECK:     .B_INPUT("DIRECT"),
// CHECK:     .CARRYINREG(32'd0),
// CHECK:     .CARRYINSELREG(32'd0),
// CHECK:     .CREG(32'd1),
// CHECK:     .DREG(32'd0),
// CHECK:     .INMODEREG(32'd0),
// CHECK:     .IS_ALUMODE_INVERTED(4'h0),
// CHECK:     .IS_CARRYIN_INVERTED(1'h0),
// CHECK:     .IS_CLK_INVERTED(1'h0),
// CHECK:     .IS_INMODE_INVERTED(5'h00),
// CHECK:     .IS_OPMODE_INVERTED(9'h000),
// CHECK:     .IS_RSTALLCARRYIN_INVERTED(1'h0),
// CHECK:     .IS_RSTALUMODE_INVERTED(1'h0),
// CHECK:     .IS_RSTA_INVERTED(1'h0),
// CHECK:     .IS_RSTB_INVERTED(1'h0),
// CHECK:     .IS_RSTCTRL_INVERTED(1'h0),
// CHECK:     .IS_RSTC_INVERTED(1'h0),
// CHECK:     .IS_RSTD_INVERTED(1'h0),
// CHECK:     .IS_RSTINMODE_INVERTED(1'h0),
// CHECK:     .IS_RSTM_INVERTED(1'h0),
// CHECK:     .IS_RSTP_INVERTED(1'h0),
// CHECK:     .MASK(48'h000000000000),
// CHECK:     .MREG(32'd1),
// CHECK:     .OPMODEREG(32'd1),
// CHECK:     .PATTERN(48'h000000000000),
// CHECK:     .PREADDINSEL("A"),
// CHECK:     .PREG(32'd1),
// CHECK:     .RND(48'h000000000000),
// CHECK:     .SEL_MASK("C"),
// CHECK:     .SEL_PATTERN("ROUNDING_MODE2"),
// CHECK:     .USE_MULT("DYNAMIC"),
// CHECK:     .USE_PATTERN_DETECT("PATDET"),
// CHECK:     .USE_SIMD("ONE48"),
// CHECK:     .USE_WIDEXOR("FALSE"),
// CHECK:     .XORSIMD("XOR24_48_96")
// CHECK:   ) DSP48E2_0 (
// CHECK:     .A({ 21'h000000, a }),
// CHECK:     .ACIN(30'h00000000),
// CHECK:     .ALUMODE(4'he),
// CHECK:     .B({ b[8], b[8], b[8], b[8], b[8], b[8], b[8], b[8], b[8], b }),
// CHECK:     .BCIN(18'h00000),
// CHECK:     .C({ 39'h0000000000, c }),
// CHECK:     .CARRYCASCIN(1'h0),
// CHECK:     .CARRYIN(1'h0),
// CHECK:     .CARRYINSEL(3'h6),
// CHECK:     .CEA1(1'h1),
// CHECK:     .CEA2(1'h1),
// CHECK:     .CEAD(1'h1),
// CHECK:     .CEALUMODE(1'h1),
// CHECK:     .CEB1(1'h1),
// CHECK:     .CEB2(1'h1),
// CHECK:     .CEC(1'h1),
// CHECK:     .CECARRYIN(1'h1),
// CHECK:     .CECTRL(1'h1),
// CHECK:     .CED(1'h1),
// CHECK:     .CEINMODE(1'h1),
// CHECK:     .CEM(1'h1),
// CHECK:     .CEP(1'h1),
// CHECK:     .CLK(clk),
// CHECK:     .D({ 18'h00000, d }),
// CHECK:     .INMODE(5'h04),
// CHECK:     .MULTSIGNIN(1'h0),
// CHECK:     .OPMODE(9'h0b5),
// CHECK:     .P({ P_0[47:9], out }),
// CHECK:     .PCIN(48'h000000000000),
// CHECK:     .RSTA(1'h0),
// CHECK:     .RSTALLCARRYIN(1'h0),
// CHECK:     .RSTALUMODE(1'h0),
// CHECK:     .RSTB(1'h0),
// CHECK:     .RSTC(1'h0),
// CHECK:     .RSTCTRL(1'h0),
// CHECK:     .RSTD(1'h0),
// CHECK:     .RSTINMODE(1'h0),
// CHECK:     .RSTM(1'h0),
// CHECK:     .RSTP(1'h0)
// CHECK:   );
// CHECK:   assign P_0[8] = out[8];
// CHECK:   assign P_0[7] = out[7];
// CHECK:   assign P_0[6] = out[6];
// CHECK:   assign P_0[5] = out[5];
// CHECK:   assign P_0[4] = out[4];
// CHECK:   assign P_0[3] = out[3];
// CHECK:   assign P_0[2] = out[2];
// CHECK:   assign P_0[1] = out[1];
// CHECK:   assign P_0[0] = out[0];
// CHECK: endmodule
