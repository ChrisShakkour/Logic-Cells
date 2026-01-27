# Fixed Priority Arbitration

Fixed-priority arbitration is the simplest arbiter policy: you hard-code an order of importance between requesters, and the **highest-priority requester that is currently requesting wins** every cycle.

## What it does (behavior)
Assume you have $N$ requesters with request signals `req[N-1:0]` and grant outputs `gnt[N-1:0]`. You also define a fixed priority order, typically:

- requester 0 = highest priority
- requester $N-1$ = lowest priority

Then the arbiter produces a **one-hot grant**:

- `gnt[i] = 1` for the first (highest-priority) `req[i] == 1`
- all other `gnt[j != i] = 0`
- if nobody requests: all grants are 0

### Example (4 requesters)
Priority: `req0 > req1 > req2 > req3`

| req3 req2 req1 req0 | Winner | gnt3 gnt2 gnt1 gnt0 |
|---|---|---|
| 0 0 0 0 | none | 0 0 0 0 |
| 0 0 0 1 | 0 | 0 0 0 1 |
| 0 1 1 0 | 1 | 0 0 1 0 |
| 1 1 1 1 | 0 | 0 0 0 1 |

## Why it’s popular
- **Very small area**: mostly AND/OR gates.
- **Very fast**: can be a short combinational path, especially for small $N$.
- **Deterministic**: same requests → same winner.

## The main downside: starvation
Because priority never changes, a high-priority requester can dominate:

- If `req0` is asserted frequently (or continuously), lower requesters may **never** get granted.
- This makes fixed-priority a bad fit for “fair sharing” resources unless traffic patterns are controlled.

## Typical implementation idea
For priority from low index to high index:

- `gnt0 = req0`
- `gnt1 = req1 & ~req0`
- `gnt2 = req2 & ~(req0 | req1)`
- `gnt3 = req3 & ~(req0 | req1 | req2)`

This guarantees the first active request wins.

## Common use cases
- Interrupt controllers (priority levels matter)
- Simple buses / low-cost microcontrollers
- Any place where “urgent wins” is acceptable and starvation is either OK or prevented elsewhere (timeouts, software scheduling, etc.)

## Files in this folder
- `FixedPriorityArbitration.sv` — RTL module (currently a skeleton).
- `FixedPriorityArbitrationTb.sv` — testbench (currently a skeleton).
