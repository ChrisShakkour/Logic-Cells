# Round Robin Arbitration

A round-robin arbiter is a **fair, stateful** arbiter policy: it behaves like a fixed-priority arbiter, except the priority order **rotates over time** so that no requester is permanently “more important” than the others.

This folder implements a synchronous round-robin policy using a simple, hardware-friendly structure:

1. **Rotate** the request vector so the current priority pointer becomes bit 0
2. Run a **fixed-priority select** (first-1 wins) on the rotated request vector
3. **Un-rotate** the resulting one-hot grant back to the original requester indices
4. If a grant happened, advance the pointer to **winner + 1**

## What it does (behavior)

Given $N$ requesters with request signals `req[N-1:0]`, the arbiter produces:

- `grant[N-1:0]`: **one-hot** grant (at most one requester is granted)
- `any_grant`: high when any requester is granted (`|grant`)
- `grant_idx`: the index of the granted requester (the position of the 1 in `grant`)

Fairness comes from an internal pointer `rr_ptr` that marks the **highest-priority requester for the next cycle**. When multiple requesters are active, the winner is the first asserted request encountered when scanning starting at `rr_ptr` and wrapping around.

### Example (4 requesters)
Assume `rr_ptr = 2` (requester 2 is currently highest priority).

| req3 req2 req1 req0 | Scan order | Winner | grant3 grant2 grant1 grant0 |
|---|---|---|---|
| 0 0 0 0 | 2,3,0,1 | none | 0 0 0 0 |
| 1 0 1 0 | 2,3,0,1 | 3 | 1 0 0 0 |
| 1 0 1 1 | 2,3,0,1 | 3 | 1 0 0 0 |
| 0 1 1 1 | 2,3,0,1 | 2 | 0 1 0 0 |

After a successful grant, the pointer advances to `winner + 1` (wrapping back to 0 after `N-1`).

## Interface

Module: `RoundRobinArbitration`

Parameters:
- `N_ARBITER_CLIENTS` (default 4): number of requesters ($N$). Must be $> 1$.
- `W_GRANT_INDEX` (localparam): `$clog2(N_ARBITER_CLIENTS)`

Ports:
- `clk`: clock (posedge)
- `rstn`: active-low asynchronous reset
- `req[N_ARBITER_CLIENTS-1:0]`: request vector
- `grant[N_ARBITER_CLIENTS-1:0]`: one-hot grant
- `any_grant`: OR-reduction of `grant`
- `grant_idx[W_GRANT_INDEX-1:0]`: index of the granted requester

## Implementation details

### Rotation-based selection
Internally, the design builds a rotated request vector `req_shift` such that:
- `req_shift[0]` corresponds to `req[rr_ptr]`
- `req_shift[1]` corresponds to `req[rr_ptr + 1]`
- … wrapping modulo $N$

Then it chooses the first asserted bit in `req_shift` using a fixed-priority loop with `break`. The resulting one-hot `grant_shift` is un-rotated back into `grant`.

### Pointer update rule
- If `any_grant == 0`: keep `rr_ptr` unchanged
- If `any_grant == 1`: set next `rr_ptr` to `(grant_idx + 1) mod N`

On reset, `rr_ptr` is cleared to 0.

## Notes / caveats

- This arbiter is **stateful** (unlike purely combinational fixed-priority arbitration), so it requires `clk`/`rstn`.
- `grant_idx` is derived from the one-hot `grant`. If no grant occurs, `grant_idx` holds its default value from combinational logic (currently `0`). Consumers should generally gate use of `grant_idx` with `any_grant`.

## Files in this folder
- `RoundRobinArbitration.sv` — RTL module
- `RoundRobinArbitrationTb.sv` — self-checking testbench
