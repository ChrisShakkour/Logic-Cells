`timescale 1ns/1ps

module RoundRobinArbitrationTb;
	localparam int unsigned N_ARBITER_CLIENTS = 8;
	localparam int unsigned W_GRANT_INDEX = $clog2(N_ARBITER_CLIENTS);

	logic                         clk;
	logic                         rstn;
	logic [N_ARBITER_CLIENTS-1:0] req;
	logic [N_ARBITER_CLIENTS-1:0] grant;
	logic                         any_grant;
	logic [W_GRANT_INDEX-1:0]      grant_idx;

	RoundRobinArbitration #(
		.N_ARBITER_CLIENTS(N_ARBITER_CLIENTS)
	) dut (
		.clk(clk),
		.rstn(rstn),
		.req(req),
		.grant(grant),
		.any_grant(any_grant),
		.grant_idx(grant_idx)
	);

	// Reference model pointer
	logic [W_GRANT_INDEX-1:0] rr_ptr;

	function automatic logic [N_ARBITER_CLIENTS-1:0] model_grant(
		input logic [N_ARBITER_CLIENTS-1:0] req_i,
		input logic [W_GRANT_INDEX-1:0]      ptr_i
	);
		logic [N_ARBITER_CLIENTS-1:0] g;
		g = '0;
		for (int unsigned k = 0; k < N_ARBITER_CLIENTS; k++) begin
			int unsigned idx;
			idx = (ptr_i + k);
			if (idx >= N_ARBITER_CLIENTS) idx -= N_ARBITER_CLIENTS;
			if (req_i[idx]) begin
				g[idx] = 1'b1;
				break;
			end
		end
		return g;
	endfunction

	function automatic logic [W_GRANT_INDEX-1:0] model_grant_idx(
		input logic [N_ARBITER_CLIENTS-1:0] req_i,
		input logic [W_GRANT_INDEX-1:0]      ptr_i
	);
		for (int unsigned k = 0; k < N_ARBITER_CLIENTS; k++) begin
			int unsigned idx;
			idx = (ptr_i + k);
			if (idx >= N_ARBITER_CLIENTS) idx -= N_ARBITER_CLIENTS;
			if (req_i[idx]) begin
				return logic'(idx[W_GRANT_INDEX-1:0]);
			end
		end
		return '0;
	endfunction

	task automatic step_and_check(input logic [N_ARBITER_CLIENTS-1:0] req_i);
		logic [N_ARBITER_CLIENTS-1:0] exp_g;
		logic [W_GRANT_INDEX-1:0]      exp_idx;

		req = req_i;
		@(posedge clk);
		#1;

		exp_g = model_grant(req_i, rr_ptr);
		exp_idx = model_grant_idx(req_i, rr_ptr);

		if (grant !== exp_g) begin
			$display("ERROR: grant mismatch req=%b ptr=%0d exp_g=%b got_g=%b", req_i, rr_ptr, exp_g, grant);
			$fatal(1);
		end
		if (any_grant !== (|exp_g)) begin
			$display("ERROR: any_grant mismatch req=%b ptr=%0d exp_any=%0d got_any=%0d", req_i, rr_ptr, (|exp_g), any_grant);
			$fatal(1);
		end
		if (any_grant) begin
			if (grant_idx !== exp_idx) begin
				$display("ERROR: grant_idx mismatch req=%b ptr=%0d exp_idx=%0d got_idx=%0d", req_i, rr_ptr, exp_idx, grant_idx);
				$fatal(1);
			end
		end

		// One-hot (or zero) check
		if ((grant != '0) && ((grant & (grant - 1)) != '0)) begin
			$display("ERROR: grant not one-hot req=%b grant=%b", req_i, grant);
			$fatal(1);
		end

		// Update model pointer after observing the decision.
		if (|exp_g) begin
			if (exp_idx == (N_ARBITER_CLIENTS - 1)) rr_ptr = '0;
			else rr_ptr = exp_idx + 1'b1;
		end
	endtask

	// Clock
	initial begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end

	initial begin
		rstn = 1'b0;
		req = '0;
		rr_ptr = '0;

		repeat (3) @(posedge clk);
		rstn = 1'b1;
		@(posedge clk);
		#1;

		// Directed: all requesters asserted, verify rotation.
		for (int unsigned t = 0; t < 3 * N_ARBITER_CLIENTS; t++) begin
			step_and_check({N_ARBITER_CLIENTS{1'b1}});
		end

		// Directed: single requester should always win.
		rr_ptr = '0;
		for (int unsigned t = 0; t < 20; t++) begin
			step_and_check('b1000_0000);
		end

		// Randomized traffic
		rr_ptr = '0;
		for (int unsigned t = 0; t < 500; t++) begin
			step_and_check($urandom());
		end

		$display("PASS: RoundRobinArbitrationTb");
		$finish;
	end
endmodule
