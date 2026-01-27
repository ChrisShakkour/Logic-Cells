// Barrel Left Shifter (shell)
//
// Synopsis:
//   Variable left shift implemented as a barrel shifter.

`timescale 1ns/1ps

module BarrelLeftShifter #(
	parameter int unsigned DATA_W  = 32,
	parameter int unsigned SHIFT_W = $clog2(DATA_W)
) (
	input  logic [DATA_W-1:0]  data_in,
	input  logic [SHIFT_W-1:0] shift_amount,
	output logic [DATA_W-1:0]  data_out
);

	// TODO: implement

endmodule
