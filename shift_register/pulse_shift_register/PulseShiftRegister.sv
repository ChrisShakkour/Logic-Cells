// Generic pulse/bit shift register
//
// Behavior:
// - On each rising clock edge, shifts `data_in` into an internal DEPTH-deep shift register.
// - Output `data_out` is the *last stage* (oldest value) of that shift register.
// - Async active-low reset clears the register.
// - Optional synchronous clear (`soft_reset`) clears the register.
// - Shift only when `data_valid` is asserted.
//
// Owner: Christians
// Date: 2026-01-20

`timescale 1ns/1ps

module PulseShiftRegister 
#(
  parameter int unsigned W_DATA = 1,
  parameter int unsigned DEPTH = 4
)(
  input  logic                  clk,
  input  logic                  rstn,
  input  logic                  soft_reset,
  input  logic                  data_valid,
  input  logic [W_DATA-1:0]     data_in,
  output logic [W_DATA-1:0]     data_out
);

  logic [DEPTH-1:0][W_DATA-1:0] shift_reg;
  logic [DEPTH-1:0][W_DATA-1:0] next_state;
  logic                         shift_reg_en;

  always_ff @(posedge clk or negedge rstn) begin
    if(~rstn)             shift_reg <= '0;
    else if(soft_reset)   shift_reg <= '0;
    else if(shift_reg_en) shift_reg <= next_state;
  end
  assign shift_reg_en = |(shift_reg ^ next_state);

  // Shift left and append new sample at stage 0.
  assign next_state = {shift_reg[DEPTH-2:0], {W_DATA{data_valid}} & data_in};

// Output is the last stage (oldest sample)
  assign data_out = shift_reg[DEPTH-1];

`ifndef ASSERTIONS_OFF
  //cadence translate_off
  //synopsys translate_off
  initial begin
    assert (DEPTH > 1)
      else $fatal(1, "PulseShiftRegister: DEPTH must be > 1 (got %0d)", DEPTH);
  end
  //synopsys translate_on
  //cadence translate_on
`endif
endmodule