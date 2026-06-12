// Binary to Gray (shell)
//
// Synopsis:
//   Convert an unsigned binary value to its reflected Gray code.
//   gray = binary ^ (binary >> 1).

`timescale 1ns/1ps

module BinaryToGrey #(
	parameter int unsigned DATA_W = 32
) (
	input  logic [DATA_W-1:0] binary_in,
	output logic [DATA_W-1:0] gray_out
);

	assign gray_out = binary_in ^ (binary_in >> 1);

endmodule
