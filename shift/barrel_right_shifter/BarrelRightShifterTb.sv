`timescale 1ns/1ps

module BarrelRightShifterTb;
	localparam int unsigned DATA_W  = 32;
	localparam int unsigned SHIFT_W = $clog2(DATA_W);

	logic [DATA_W-1:0]  data_in;
	logic [SHIFT_W-1:0] shift_amount;
	logic [DATA_W-1:0]  data_out;

	BarrelRightShifter #(
		.DATA_W(DATA_W),
		.SHIFT_W(SHIFT_W)
	) dut (
		.data_in(data_in),
		.shift_amount(shift_amount),
		.data_out(data_out)
	);

	task automatic check(input logic [DATA_W-1:0] d, input logic [SHIFT_W-1:0] s);
		logic [DATA_W-1:0] exp;
		data_in = d;
		shift_amount = s;
		#1;
		exp = logic'(d >> s);
		if (data_out !== exp) begin
			$display("ERROR BarrelRightShifter: d=%h s=%0d exp=%h got=%h", d, s, exp, data_out);
			$fatal(1);
		end
	endtask

	initial begin
		data_in = '0;
		shift_amount = '0;
		#1;

		check(32'h8000_0000, 5);
		check(32'h1234_5678, 8);
		check(32'hFFFF_FFFF, 31);

		for (int unsigned t = 0; t < 200; t++) begin
			check($urandom(), $urandom_range(DATA_W-1, 0));
		end

		$display("PASS: BarrelRightShifterTb");
		$finish;
	end

endmodule
