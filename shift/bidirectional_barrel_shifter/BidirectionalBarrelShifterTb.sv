`timescale 1ns/1ps

module BidirectionalBarrelShifterTb;
	localparam int unsigned DATA_W  = 32;
	localparam int unsigned SHIFT_W = $clog2(DATA_W);

	logic                 dir;
	logic                 arith;
	logic [DATA_W-1:0]    data_in;
	logic [SHIFT_W-1:0]   shift_amount;
	logic [DATA_W-1:0]    data_out;

	BidirectionalBarrelShifter #(
		.DATA_W(DATA_W),
		.SHIFT_W(SHIFT_W)
	) dut (
		.dir(dir),
		.arith(arith),
		.data_in(data_in),
		.shift_amount(shift_amount),
		.data_out(data_out)
	);

	function automatic logic [DATA_W-1:0] expected(
		input logic                 dir_i,
		input logic                 arith_i,
		input logic [DATA_W-1:0]    d,
		input logic [SHIFT_W-1:0]   s
	);
		logic signed [DATA_W-1:0] ds;
		ds = d;
		if (!dir_i) begin
			return logic'(d << s);
		end
		if (arith_i) begin
			return logic'(ds >>> s);
		end
		return logic'(d >> s);
	endfunction

	task automatic check(
		input logic                 dir_i,
		input logic                 arith_i,
		input logic [DATA_W-1:0]    d,
		input logic [SHIFT_W-1:0]   s
	);
		logic [DATA_W-1:0] exp;
		dir = dir_i;
		arith = arith_i;
		data_in = d;
		shift_amount = s;
		#1;
		exp = expected(dir_i, arith_i, d, s);
		if (data_out !== exp) begin
			$display("ERROR BidirectionalBarrelShifter: dir=%0d arith=%0d d=%h s=%0d exp=%h got=%h",
				dir_i, arith_i, d, s, exp, data_out);
			$fatal(1);
		end
	endtask

	initial begin
		dir = 1'b0;
		arith = 1'b0;
		data_in = '0;
		shift_amount = '0;
		#1;

		// Left
		check(1'b0, 1'b0, 32'h0000_0001, 5);
		check(1'b0, 1'b0, 32'h1234_5678, 8);

		// Right logical
		check(1'b1, 1'b0, 32'h8000_0000, 5);
		check(1'b1, 1'b0, 32'hFFFF_FFFF, 31);

		// Right arithmetic
		check(1'b1, 1'b1, 32'h8000_0000, 5);
		check(1'b1, 1'b1, 32'hF000_0000, 4);

		for (int unsigned t = 0; t < 300; t++) begin
			logic [SHIFT_W-1:0] s;
			s = $urandom_range(DATA_W-1, 0);
			check($urandom_range(1, 0), $urandom_range(1, 0), $urandom(), s);
		end

		$display("PASS: BidirectionalBarrelShifterTb");
		$finish;
	end

endmodule
