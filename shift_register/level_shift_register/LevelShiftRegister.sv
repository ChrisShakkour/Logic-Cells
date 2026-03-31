// Level (sticky) shift register
//
// Synopsis:
// - Parameter W_DATA : width of `data_in`/`data_out`.
// - Parameter DEPTH  : number of shift stages (must be > 1).
// - When `data_valid` is 1, stage 0 samples `data_in`.
// - When `data_valid` is 0, stage 0 holds its previous value (sticky).
// - The register shifts every cycle (stage i+1 <= stage i).
// - `data_out` is the last stage (oldest sample).
//
// Notes:
// - This differs from a pulse shift register: it propagates the last valid value forward even
//   when `data_valid` is deasserted (rather than shifting in zeros).
//
// Owner: Christians
// Date: 2026-01-20

`timescale 1ns/1ps

module LevelShiftRegister 
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
  logic [W_DATA-1:0]            next_data_sticky;
  logic                         shift_reg_en;

  always_ff @(posedge clk or negedge rstn) begin
    if(~rstn)             shift_reg <= '0;
    else if(soft_reset)   shift_reg <= '0;
    else if(shift_reg_en) shift_reg <= next_state;
  end
  assign shift_reg_en = |(shift_reg ^ next_state);

  // Shift left and append new sample at stage 0.
  assign next_state = {shift_reg[DEPTH-2:0], next_data_sticky};
  assign next_data_sticky = data_valid ? data_in : shift_reg[0]; 

// Output is the last stage (oldest sample)
  assign data_out = shift_reg[DEPTH-1];

`ifndef ASSERTIONS_OFF
  //cadence translate_off
  //synopsys translate_off
  initial begin
    assert (DEPTH > 1)
      else $fatal(1, "LevelShiftRegister: DEPTH must be > 1 (got %0d)", DEPTH);
  end
  //synopsys translate_on
  //cadence translate_on
`endif
endmodule