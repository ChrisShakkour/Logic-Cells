// Clock divider (counter-based)
//
// Synopsis:
// - Generates a divided clock with ~50% duty cycle using a counter.
// - Supports ONLY even divide ratios for exact 50% duty cycle.
//
// Parameters:
// - DIVIDE_BY : even integer >= 2. Output frequency = clk_in / DIVIDE_BY.
//
// Ports:
// - clk       : input clock.
// - rstn      : async active-low reset.
// - en        : enable. When 0, holds output state and resets internal count.
// - clk_out   : divided clock output.
//
// Owner: Christians
// Date: 2026-01-22

`timescale 1ns/1ps

module ClockDivider #(
  parameter int unsigned DIVIDE_BY = 2,
  localparam int unsigned HALF_PERIOD = (DIVIDE_BY / 2),
  localparam int unsigned CNT_W = (HALF_PERIOD <= 1) ? 1 : $clog2(HALF_PERIOD)
) (
  input  logic clk,
  input  logic rstn,
  input  logic en,
  output logic clk_out
);

  logic [CNT_W-1:0] cnt;

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      cnt     <= '0;
      clk_out <= 1'b0;
    end else if (!en) begin
      // When disabled: hold output low (or keep state - choose predictable behavior).
      cnt     <= '0;
      clk_out <= 1'b0;
    end else begin
      if (cnt == HALF_PERIOD - 1) begin
        cnt     <= '0;
        clk_out <= ~clk_out;
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end

`ifndef ASSERTIONS_OFF
  //cadence translate_off
  //synopsys translate_off
  initial begin
    assert (DIVIDE_BY >= 2)
      else $fatal(1, "ClockDivider: DIVIDE_BY must be >= 2 (got %0d)", DIVIDE_BY);
    assert ((DIVIDE_BY % 2) == 0)
      else $fatal(1, "ClockDivider: DIVIDE_BY must be even for 50%% duty-cycle (got %0d)", DIVIDE_BY);
  end
  //synopsys translate_on
  //cadence translate_on
`endif

endmodule
