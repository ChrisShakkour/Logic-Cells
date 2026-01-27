`timescale 1ns/1ps

module FixedPriorityArbitrationTb;

	localparam int unsigned N_ARBITER_CLIENTS = 8;
	localparam int unsigned W_GRANT_INDEX = $clog2(N_ARBITER_CLIENTS);

	logic [N_ARBITER_CLIENTS-1:0] req;
	logic [N_ARBITER_CLIENTS-1:0] grant;
	logic                         any_grant;
	logic [W_GRANT_INDEX-1:0]      grant_idx;

	FixedPriorityArbitration #(
		.N_ARBITER_CLIENTS(N_ARBITER_CLIENTS)
	) dut (
		.req(req),
		.grant(grant),
		.any_grant(any_grant),
		.grant_idx(grant_idx)
	);

	function automatic logic [N_ARBITER_CLIENTS-1:0] expected_grant(
		input logic [N_ARBITER_CLIENTS-1:0] req_i
	);
		logic [N_ARBITER_CLIENTS-1:0] g;
		g = '0;
		for (int unsigned i = 0; i < N_ARBITER_CLIENTS; i++) begin
			if (req_i[i]) begin
				g[i] = 1'b1;
				break;
			end
		end
		return g;
	endfunction

	function automatic logic [W_GRANT_INDEX-1:0] expected_grant_idx(
		input logic [N_ARBITER_CLIENTS-1:0] req_i
	);
		for (int unsigned i = 0; i < N_ARBITER_CLIENTS; i++) begin
			if (req_i[i]) begin
				return logic'(i[W_GRANT_INDEX-1:0]);
			end
		end
		return '0;
	endfunction

	task automatic check_req(input logic [N_ARBITER_CLIENTS-1:0] req_i);
		logic [N_ARBITER_CLIENTS-1:0] exp;
		logic [W_GRANT_INDEX-1:0]      exp_idx;
		exp = expected_grant(req_i);
		exp_idx = expected_grant_idx(req_i);

		req = req_i;
		#1;

		if (grant !== exp) begin
			$display("ERROR: req=%b exp_grant=%b got_grant=%b", req_i, exp, grant);
			$fatal(1);
		end
		if (any_grant !== (|exp)) begin
			$display("ERROR: any_grant mismatch req=%b exp_any=%0d got_any=%0d", req_i, (|exp), any_grant);
			$fatal(1);
		end
		if (any_grant) begin
			if (grant_idx !== exp_idx) begin
				$display("ERROR: grant_idx mismatch req=%b exp_idx=%0d got_idx=%0d", req_i, exp_idx, grant_idx);
				$fatal(1);
			end
		end

		// One-hot (or zero) check
		if ((grant != '0) && ((grant & (grant - 1)) != '0)) begin
			$display("ERROR: grant not one-hot req=%b grant=%b", req_i, grant);
			$fatal(1);
		end
	endtask

	initial begin
		req = '0;
		#1;

		// Directed tests
		check_req('0);
		check_req({N_ARBITER_CLIENTS{1'b1}});
		check_req('b1);                 // only client 0
		check_req('b10);                // only client 1
		check_req('b100);               // only client 2
		check_req('b1010);              // clients 1 and 3
		check_req('b1100);              // clients 2 and 3
		check_req('b1000_0000);         // highest index only
		check_req('b1000_0001);         // highest and lowest -> lowest wins

		// Randomized tests
		for (int unsigned t = 0; t < 500; t++) begin
			req = $urandom();
			check_req(req);
		end

		$display("PASS: FixedPriorityArbitrationTb");
		$finish;
	end

endmodule
