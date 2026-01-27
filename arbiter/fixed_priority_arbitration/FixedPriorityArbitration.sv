// Fixed Priority Arbitration
//
// Synopsis:
//   Combinational fixed-priority arbiter.
//   - Priority is fixed from lowest index to highest index:
//       req[0] = highest priority
//       req[N_ARBITER_CLIENTS-1] = lowest priority
//   - Output is one-hot grant.

`timescale 1ns/1ps

module FixedPriorityArbitration #(
	parameter int unsigned N_ARBITER_CLIENTS = 4,
	localparam int unsigned W_GRANT_INDEX = $clog2(N_ARBITER_CLIENTS)
) (
	input  logic [N_ARBITER_CLIENTS-1:0] req,
	output logic [N_ARBITER_CLIENTS-1:0] grant,
	output logic                         any_grant,
	output logic [W_GRANT_INDEX-1:0]      grant_idx
);

	// ------------------------------------------------------------------------
	// Combinational arbitration
	// ------------------------------------------------------------------------
	always_comb begin
		grant = '0;
		grant_idx = '0;

		// Pick the first requester (lowest index) that is asserting req.
		for (int unsigned i = 0; i < N_ARBITER_CLIENTS; i++) begin
			if (req[i]) begin
				grant[i] = 1'b1;
				grant_idx = logic'(i[W_GRANT_INDEX-1:0]);
				break;
			end
		end
	end

	assign any_grant = |grant;

`ifndef ASSERTIONS_OFF
	// cadence translate_off
	// synopsys translate_off
	initial begin
		assert (N_ARBITER_CLIENTS > 1)
			else $fatal(1, "FixedPriorityArbitration: N_ARBITER_CLIENTS must be > 1");
	end
	// synopsys translate_on
	// cadence translate_on
`endif

endmodule
