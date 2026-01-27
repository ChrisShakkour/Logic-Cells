`timescale 1ns/1ps

module ShiftRightArithmaticTb;
	localparam int unsigned DATA_W  = 32;
	localparam int unsigned SHIFT_W = $clog2(DATA_W);

	logic [DATA_W-1:0]  data_in;
	logic [SHIFT_W-1:0] shift_amount;
	logic [DATA_W-1:0]  data_out;

	ShiftRightArithmatic #(
		.DATA_W(DATA_W),
		.SHIFT_W(SHIFT_W)
	) dut (
		.data_in(data_in),
		.shift_amount(shift_amount),
		.data_out(data_out)
	);

	function automatic logic [DATA_W-1:0] expected(
		input logic [DATA_W-1:0]  d,
		input logic [SHIFT_W-1:0] s
	);
		logic signed [DATA_W-1:0] ds;
		ds = d;
		return logic'(ds >>> s);
	endfunction

	task automatic check(input logic [DATA_W-1:0] d, input logic [SHIFT_W-1:0] s);
		logic [DATA_W-1:0] exp;
		data_in = d;
		shift_amount = s;
		#1;
		exp = expected(d, s);
		if (data_out !== exp) begin
			$display("ERROR ShiftRightArithmatic: d=%h s=%0d exp=%h got=%h", d, s, exp, data_out);
			$fatal(1);
		end
	endtask

	initial begin
		data_in = '0;
		shift_amount = '0;
		#1;

		// Negative and positive cases
		check(32'h8000_0000, 1);
		check(32'hF000_0000, 4);
		check(32'h7FFF_FFFF, 1);
		check(32'h1234_5678, 4);
		check(32'hFFFF_FFFF, SHIFT_W'(DATA_W-1));

		for (int unsigned t = 0; t < 200; t++) begin
			check($urandom(), $urandom_range(DATA_W-1, 0));
		end

		$display("PASS: ShiftRightArithmaticTb");
		$finish;
	end

endmodule
