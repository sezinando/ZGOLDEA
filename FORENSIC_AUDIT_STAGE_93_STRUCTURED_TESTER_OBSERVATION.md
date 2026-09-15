# FORENSIC AUDIT — STAGE 93
## Structured Tester Observation Gate

Status: PROVISIONED — execution disabled

### Objective
Prepare the first real ZGOLD Strategy Tester observation run and the handoff into the replay comparator, without enabling trading operations.

### Current ZGOLD boundary
The EA entry point explicitly identifies the current build as `NO TRADING LOGIC`. The tester pass in this stage must therefore validate compilation, initialization, tick processing, lifecycle observation and structured trace emission only.

### Required tester setup
- Symbol: XAUUSD
- Digits: 2
- Point: 0.01
- Reference interval: 2026.06.01 01:00:00 through 2026.06.02 12:04:01
- Reference source: `ZEUS_STAGE92_REFERENCE_TRACE.csv`
- Initial Magic: 1001
- Execution: disabled

### Acceptance gate
The observation pass is accepted only when all of the following are available:
1. Successful compilation of `ZGOLD.mq4` and included modules in the user's MT4 terminal.
2. Tester run starts and processes the selected XAUUSD interval.
3. ZGOLD lifecycle/state trace is emitted in machine-readable form.
4. The resulting observed trace can be normalized into the same event vocabulary used by the Zeus reference:
   `CREATE`, `MODIFY`, `EXECUTE`, `CLOSEBY` and later extended events.
5. No trading API call is made during this pass.

### Important limitation
The current environment does not provide an MT4 Strategy Tester runtime. Therefore this stage establishes the gate and comparison handoff but does not claim that an MT4 tester run has actually been executed here.

### Reference baseline validation
The available Stage 92 reference trace contains 1,004 rows:
- CREATE: 227
- MODIFY: 500
- EXECUTE: 221
- CLOSEBY: 56

The trace is chronologically ordered and preserves ticket identity. Its schema is:
`Timestamp;EventType;Ticket;Direction;Lots;Price;ByTicket`

This is sufficient for the first lifecycle-level comparison, but it does not yet contain the full 27-field `ReplayTraceRecord` state/decision schema. Missing decision/state fields must therefore remain `UNRESOLVED`, not be synthesized.

### Comparison rule
The first available ZGOLD trace will be aligned against the Zeus baseline. A mismatch will be classified only when the relevant field is actually present on both sides. The comparator must not manufacture a D2/D5 divergence from reference fields that do not exist.

### Outcome of Stage 93
This stage moves the project from `reference-only` to `tester-ready`. The next practical artifact required is a ZGOLD Strategy Tester observation trace generated from the user's MT4 installation.

### Next stage
Stage 94 — First ZGOLD Tester Trace Capture and normalization, followed by the first actual Zeus-vs-ZGOLD causal comparison.
