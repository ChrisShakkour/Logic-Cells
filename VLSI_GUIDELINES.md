# VLSI / RTL Design Guidelines

Owner: Christians  
Last Updated: 2026-01-22

This guide defines coding, verification, and signoff expectations for RTL blocks in `Logic-Cells/`.
The goals are:
- clean, maintainable RTL
- predictable synthesis results
- CDC/RDC-safe integration
- low-noise lint

---

## 1) Scope & conventions

### Languages
- SystemVerilog for RTL and testbenches.
- Prefer synthesizable SV constructs: `logic`, `always_ff`, `always_comb`, `typedef`, packed structs/enums.

### Naming
- Modules: `PascalCase` (e.g., `PulseShiftRegister`).
- Signals/ports: `snake_case` (e.g., `data_valid`, `soft_reset`).
- Parameters: `ALL_CAPS` (e.g., `W_DATA`, `DEPTH`).
- Localparams: `ALL_CAPS` (e.g., `W_DATA`, `DEPTH`).
- Active-low resets end with `n` (e.g., `rstn`, `por_n`).

### File naming
- One main module per file and file name matches module name: `PulseShiftRegister.sv`.
- Testbench file naming: `<ModuleName>Tb.sv`.
- Block directory naming (if used): lowercase with underscores (e.g., `pulse_shift_register/`).

---

## 2) RTL coding style

### Sequential logic
- Use `always_ff @(posedge clk or negedge rstn)` for flops with async reset.
- Use non-blocking assignments (`<=`) inside sequential blocks.
- Don’t infer latches.
- Use `soft_reset` as a sync reset.

### Combinational logic
- Use `always_comb` for combinational processes.
- Provide defaults at the top of `always_comb` to avoid latches.
- Prefer explicit sizing/casting when mixing widths.

### Use explicit enables
- Don’t infer enables by comparing current vs next state (often creates width/lint issues).
- If the design intent is “shift only when valid”, implement it explicitly:
    - `shift_en = data_valid;`

### Parameters and legality checks
- Always put paramater and localparam in the parameter decleration.
- Sanity-check key parameters using assertions (compile/sim-time).
- Guard assertions with:
    - `` `ifndef ASSERTIONS_OFF ``
    - `` //cadence translate_off/on``
    - `` //synopsys translate_off/on``

---

## 3) Reset strategy

### Reset types
- Prefer synchronous clears (`soft_reset`) for functional clearing.
- Async reset is allowed for bringing flops to a known boot state.

### Reset rules
- Define deterministic reset values.
- Avoid multiple async resets in the same domain unless reviewed.

---

## 4) CDC / RDC (Clock/Reset Domain Crossing)

### CDC rules
- Any signal crossing clock domains must be handled explicitly:
  - Single-bit control: 2-flop synchronizer (or handshake).
  - Multi-bit: CDC-safe handshakes, async FIFOs, or gray coding.
- No combinational logic on asynchronous signals before synchronization.

### Reset crossing
- Reset deassertion should be synchronized per receiving domain unless proven safe.

---

## 5) Lint rules (must pass)

### General
- No implicit nets.
- No undeclared identifiers.
- No unused signals/ports (unless intentionally reserved and documented).
- Avoid scalar assignment from vectors/arrays without reduction or explicit cast.

### Common gotchas
- Don’t do this:
  - `logic en; assign en = (a ^ b);` when `(a ^ b)` is a bus/array.
- If you truly mean “any bit differs”, use a reduction:
  - `assign en = |(a ^ b);`
- But prefer intent-driven enables (e.g., `data_valid`) over derived-change enables.

---

## 6) Assertions & translate directives

### Assertions
- Immediate assertions are recommended for parameter legality.
- Protocol assertions are recommended for interfaces when applicable.
- Always put assertions at the end of the moduile, before the endmodule.

### translate_off/on
- For simulation-only blocks (assertions, debug), you may wrap with:
  - `//cadence translate_off`
  - `//synopsys translate_off`
  - and corresponding `translate_on`

---

## 7) Testbenches

Each block should have at least a minimal TB that:
- generates clock/reset
- provides basic stimulus
- ideally includes self-checking for 1–2 key behaviors

---

## 8) Review checklist (PR / signoff gate)

Before marking a block "done":
- [ ] compiles (no missing declarations)
- [ ] lint clean (or waivers documented and justified)
- [ ] parameter legality assumptions asserted
- [ ] TB present and runnable
- [ ] CDC reviewed (if applicable)
- [ ] naming/files/structure follow conventions
