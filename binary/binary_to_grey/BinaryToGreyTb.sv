`timescale 1ns/1ps

module BinaryToGreyTb;
	localparam int unsigned DATA_W = 32;

	logic [DATA_W-1:0] binary_in;
	logic [DATA_W-1:0] gray_out;

	BinaryToGrey #(
		.DATA_W(DATA_W)
	) dut (
		.binary_in(binary_in),
		.gray_out(gray_out)
	);

	function automatic logic [DATA_W-1:0] expected(input logic [DATA_W-1:0] b);
		return b ^ (b >> 1);
	endfunction

	task automatic check(input logic [DATA_W-1:0] b);
		logic [DATA_W-1:0] exp;
		binary_in = b;
		#1;
		exp = expected(b);
		if (gray_out !== exp) begin
			$display("ERROR BinaryToGrey: b=%h exp=%h got=%h", b, exp, gray_out);
			$fatal(1);
		end
	endtask

	initial begin
		binary_in = '0;
		#1;

		check(32'h0000_0000);
		check(32'h0000_0001);
		check(32'h0000_0002);
		check(32'h8000_0000);
		check(32'hFFFF_FFFF);
		check(32'h1234_5678);

		for (int unsigned t = 0; t < 200; t++) begin
			check($urandom());
		end

		$display("PASS: BinaryToGreyTb");
		$finish;
	end

endmodule
