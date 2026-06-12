`timescale 1ns/1ps

module GreyToBinaryTb;
	localparam int unsigned DATA_W = 32;

	logic [DATA_W-1:0] gray_in;
	logic [DATA_W-1:0] binary_out;

	GreyToBinary #(
		.DATA_W(DATA_W)
	) dut (
		.gray_in(gray_in),
		.binary_out(binary_out)
	);

	function automatic logic [DATA_W-1:0] expected(input logic [DATA_W-1:0] g);
		logic [DATA_W-1:0] b;
		b[DATA_W-1] = g[DATA_W-1];
		for (int i = DATA_W-2; i >= 0; i--) begin
			b[i] = b[i+1] ^ g[i];
		end
		return b;
	endfunction

	task automatic check(input logic [DATA_W-1:0] g);
		logic [DATA_W-1:0] exp;
		gray_in = g;
		#1;
		exp = expected(g);
		if (binary_out !== exp) begin
			$display("ERROR GreyToBinary: g=%h exp=%h got=%h", g, exp, binary_out);
			$fatal(1);
		end
	endtask

	initial begin
		gray_in = '0;
		#1;

		check(32'h0000_0000);
		check(32'h0000_0001);
		check(32'h0000_0003);
		check(32'hC000_0000);
		check(32'hFFFF_FFFF);
		check(32'h1234_5678);

		for (int unsigned t = 0; t < 200; t++) begin
			check($urandom());
		end

		$display("PASS: GreyToBinaryTb");
		$finish;
	end

endmodule
