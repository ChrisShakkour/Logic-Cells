# Arbitration Logic Overview

This document summarizes **widely used hardware arbitration logics**, their principles, tradeoffs, and common use cases.  
It is intended as a reference for **SoC, interconnect, cache, and bus designers**.

---

## 1. Fixed Priority Arbitration

**Concept**  
A static priority order is defined. The highest-priority active requester always wins.

**Characteristics**
- Simple combinational logic
- Fast arbitration
- Starvation possible for low-priority requesters

**Pros**
- Minimal area
- Short critical path
- Easy verification

**Cons**
- Unfair
- Not suitable for shared high-traffic resources

**Typical Use Cases**
- Interrupt controllers
- Simple buses
- Low-cost microcontrollers

---

## 2. Round-Robin Arbitration

**Concept**  
Priority rotates after each grant to ensure fairness.

**Characteristics**
- Maintains a rotating pointer
- Wrap-around logic required

**Pros**
- Fair
- No starvation
- Predictable behavior

**Cons**
- Slightly higher area
- Longer critical path than fixed priority

**Typical Use Cases**
- AXI / AMBA interconnects
- DMA controllers
- Network-on-Chip (NoC)

---

## 3. Rotating Priority Arbitration

**Concept**  
Generalized form of round-robin where priority rotation rules are configurable.

**Variants**
- Rotate on grant
- Rotate on cycle
- Rotate on request arrival

**Pros**
- Flexible fairness control
- Configurable policies

**Cons**
- More control logic
- Increased verification complexity

**Typical Use Cases**
- High-performance interconnect IP
- Configurable arbitration blocks

---

## 4. Least Recently Used (LRU)

**Concept**  
The requester least recently granted access is served next.

**Characteristics**
- Tracks access history
- Strong fairness guarantees

**Pros**
- Prevents starvation
- Balances long-term access

**Cons**
- State-heavy
- Poor scalability for large N

**Typical Use Cases**
- Cache controllers
- Memory schedulers
- High-end SoCs

---

## 5. Weighted Round-Robin (WRR)

**Concept**  
Each requester is assigned a weight representing its bandwidth share.

**Characteristics**
- Multiple grants per round proportional to weight

**Pros**
- Quality of Service (QoS) support
- Fair with prioritization

**Cons**
- Additional counters/state
- Increased logic complexity

**Typical Use Cases**
- Memory controllers
- Network switches
- Real-time systems

---

## 6. Deficit Round-Robin (DRR)

**Concept**  
An extension of WRR that supports variable transaction sizes.

**Characteristics**
- Uses deficit counters
- Efficient for burst traffic

**Pros**
- Fair over time
- Better utilization for variable-size requests

**Cons**
- More arithmetic logic
- Slightly higher latency

**Typical Use Cases**
- Packet-based systems
- DMA engines
- NoC routers

---

## 7. Time-Division Multiplexing (TDM)

**Concept**  
Fixed time slots are allocated to each requester.

**Characteristics**
- Static scheduling
- Deterministic access

**Pros**
- Guaranteed latency
- Easy timing analysis

**Cons**
- Poor utilization if slots are idle
- Inflexible under dynamic loads

**Typical Use Cases**
- Safety-critical systems
- Automotive and aerospace
- Hard real-time SoCs

---

## 8. Lottery Arbitration

**Concept**  
Requesters hold “tickets”; a random draw selects the winner.

**Characteristics**
- Probabilistic fairness
- Randomized selection

**Pros**
- Simple weighted fairness
- Avoids starvation statistically

**Cons**
- Non-deterministic behavior
- Rarely used in production hardware

**Typical Use Cases**
- Research systems
- Experimental NoCs

---

## 9. Matrix (Grant-Matrix) Arbitration

**Concept**  
Each requester is compared against all others in a full matrix.

**Characteristics**
- N × N comparison matrix
- Fully parallel arbitration

**Pros**
- Very fast for small N
- Single-cycle decisions

**Cons**
- Area scales as O(N²)
- Not scalable

**Typical Use Cases**
- Crossbar switches
- Small-N high-speed arbiters

---

## 10. Hierarchical Arbitration

**Concept**  
Multiple arbitration stages arranged hierarchically.

**Characteristics**
- Local arbiters feed higher-level arbiters

**Pros**
- Scales well
- Shorter critical paths per stage

**Cons**
- Increased latency
- Complex control and debug

**Typical Use Cases**
- Large NoCs
- Multi-core SoCs
- Chiplet-based systems

---

## 11. Speculative / Lookahead Arbitration

**Concept**  
Arbitration begins before the current transaction completes.

**Characteristics**
- Overlaps arbitration with execution

**Pros**
- Higher throughput
- Reduced idle cycles

**Cons**
- Complex control logic
- Hard to verify corner cases

**Typical Use Cases**
- CPUs
- GPUs
- DRAM controllers

---

## 12. Token-Based Arbitration

**Concept**  
A circulating token grants access to the holder.

**Characteristics**
- Token passes between requesters

**Pros**
- Simple fairness
- Low logic overhead

**Cons**
- Token latency
- Token loss handling required

**Typical Use Cases**
- Ring interconnects
- Legacy bus architectures

---

## Summary Comparison

| Arbitration Type | Fairness | Area | Speed | Typical Use |
|------------------|----------|------|-------|-------------|
| Fixed Priority   | ❌       | Low  | High  | Simple buses |
| Round Robin      | ✅       | Low  | Medium| Interconnects |
| WRR / DRR        | ✅       | Med  | Medium| QoS systems |
| LRU              | ✅       | High | Low   | Caches |
| TDM              | ✅       | Low  | High  | Real-time |
| Matrix           | ⚠️       | High | High  | Small-N |
| Hierarchical     | ✅       | Med  | Med   | Large systems |

---

## Notes
- No single arbitration scheme is optimal for all systems.
- Choice depends on **fairness**, **latency**, **area**, **scalability**, and **QoS requirements**.
- Many real-world systems combine multiple arbitration schemes hierarchically.
