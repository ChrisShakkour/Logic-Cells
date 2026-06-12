// Gray to Binary (shell)
//
// Synopsis:
//   Convert a reflected Gray code value back to unsigned binary.
//   binary[i] = ^(gray >> i)  (XOR-prefix of the Gray bits).

`timescale 1ns/1ps

module GreyToBinary #(
	parameter int unsigned DATA_W = 32
) (
	input  logic [DATA_W-1:0] gray_in,
	output logic [DATA_W-1:0] binary_out
);

	// binary[i] = XOR of all gray bits from MSB down to i
	genvar i;
	generate
		for (i = 0; i < DATA_W; i++) begin : g_xor_prefix
			assign binary_out[i] = ^(gray_in >> i);
		end
	endgenerate

endmodule
