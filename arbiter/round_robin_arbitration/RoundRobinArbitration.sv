// Round Robin Arbitration
//
// Synopsis:
//   Fair, stateful round-robin arbiter.
//   - Maintains a rotating priority pointer.
//   - On each cycle, the first requester at/after the pointer wins.
//   - After a successful grant, the pointer advances to (granted_idx + 1).
//
// Notes:
//   This arbiter is synchronous (needs clk/rstn) to maintain fairness over time.

`timescale 1ns/1ps

module RoundRobinArbitration #(
	parameter int unsigned N_ARBITER_CLIENTS = 4,
	localparam int unsigned W_GRANT_INDEX = $clog2(N_ARBITER_CLIENTS)
) (
	input  logic                         clk,
	input  logic                         rstn,
	input  logic [N_ARBITER_CLIENTS-1:0] req,
	output logic [N_ARBITER_CLIENTS-1:0] grant,
	output logic                         any_grant,
	output logic [W_GRANT_INDEX-1:0]      grant_idx
);

	logic [W_GRANT_INDEX-1:0] rr_ptr_q;
	logic [W_GRANT_INDEX-1:0] rr_ptr_d;

	logic [N_ARBITER_CLIENTS-1:0] req_shift;
	logic [N_ARBITER_CLIENTS-1:0] grant_shift;
	logic [W_GRANT_INDEX-1:0]      sel_idx;

	// ------------------------------------------------------------------------
	// Combinational select
	// ------------------------------------------------------------------------
	always_comb begin
		req_shift = '0;
		grant_shift = '0;
		grant = '0;
		sel_idx = rr_ptr_q;
		grant_idx = '0;

		// Rotate req so that rr_ptr_q becomes bit 0 (highest priority).
		for (int unsigned k = 0; k < N_ARBITER_CLIENTS; k++) begin
			int unsigned idx;
			idx = (rr_ptr_q + k);
			if (idx >= N_ARBITER_CLIENTS) idx -= N_ARBITER_CLIENTS;
			req_shift[k] = req[idx];
		end

		// Fixed-priority arbitration on the shifted request vector.
		for (int unsigned k = 0; k < N_ARBITER_CLIENTS; k++) begin
			if (req_shift[k]) begin
				grant_shift[k] = 1'b1;
				break;
			end
		end

		// Un-rotate grant back to original requester indices.
		for (int unsigned k = 0; k < N_ARBITER_CLIENTS; k++) begin
			int unsigned idx;
			idx = (rr_ptr_q + k);
			if (idx >= N_ARBITER_CLIENTS) idx -= N_ARBITER_CLIENTS;
			grant[idx] = grant_shift[k];
		end

		// Compute granted index in original domain.
		for (int unsigned i = 0; i < N_ARBITER_CLIENTS; i++) begin
			if (grant[i]) begin
				sel_idx = logic'(i[W_GRANT_INDEX-1:0]);
				break;
			end
		end
		grant_idx = sel_idx;
	end

	assign any_grant = |grant;

	// ------------------------------------------------------------------------
	// Pointer update
	// ------------------------------------------------------------------------
	always_comb begin
		rr_ptr_d = rr_ptr_q;
		if (any_grant) begin
			// Next cycle's highest priority is (winner + 1)
			if (sel_idx == (N_ARBITER_CLIENTS - 1)) begin
				rr_ptr_d = '0;
			end else begin
				rr_ptr_d = sel_idx + 1'b1;
			end
		end
	end

	always_ff @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			rr_ptr_q <= '0;
		end else begin
			rr_ptr_q <= rr_ptr_d;
		end
	end

`ifndef ASSERTIONS_OFF
	// cadence translate_off
	// synopsys translate_off
	initial begin
		assert (N_ARBITER_CLIENTS > 1)
			else $fatal(1, "RoundRobinArbitration: N_ARBITER_CLIENTS must be > 1");
	end
	// synopsys translate_on
	// cadence translate_on
`endif

endmodule
