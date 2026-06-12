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

	logic [DATA_W-1:0] stage [SHIFT_W+1];

	assign stage[0] = data_in;

	for (genvar i = 0; i < SHIFT_W; i++) begin : gen_stage
		assign stage[i+1] = shift_amount[i] ? (stage[i] << (1 << i)) : stage[i];
	end

	assign data_out = stage[SHIFT_W];

endmodule
