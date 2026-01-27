// Bidirectional Barrel Shifter (shell)
//
// Synopsis:
//   Variable shift left/right implemented as a barrel shifter.
//   Direction is selected via `dir`.

`timescale 1ns/1ps

module BidirectionalBarrelShifter #(
	parameter int unsigned DATA_W  = 32,
	parameter int unsigned SHIFT_W = $clog2(DATA_W)
) (
	input  logic                 dir,       // 0: left, 1: right
	input  logic                 arith,     // when dir=1: 1 = arithmetic right shift, 0 = logical
	input  logic [DATA_W-1:0]    data_in,
	input  logic [SHIFT_W-1:0]   shift_amount,
	output logic [DATA_W-1:0]    data_out
);

	// TODO: implement

endmodule
