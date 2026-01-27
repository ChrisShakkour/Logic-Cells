// Shift Right Logical (shell)
//
// Synopsis:
//   Logical right shift: shift in zeros on MSB side.

`timescale 1ns/1ps

module ShiftRightLogical #(
	parameter int unsigned DATA_W  = 32,
	parameter int unsigned SHIFT_W = $clog2(DATA_W)
) (
	input  logic [DATA_W-1:0]  data_in,
	input  logic [SHIFT_W-1:0] shift_amount,
	output logic [DATA_W-1:0]  data_out
);

	// TODO: implement

endmodule
