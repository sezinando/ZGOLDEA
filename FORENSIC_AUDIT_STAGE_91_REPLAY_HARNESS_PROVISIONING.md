# FORENSIC AUDIT — STAGE 91
## Replay Comparator Harness — Provisioning

Status: PROVISIONED — execution disabled

### Objective
Create the controlled bridge that accepts one forensic Zeus reference record and one ZGOLD observed record, aligns them, compares their dimensions and classifies the first detected divergence.

### Safety boundary
This stage is observation/comparison only.

- No `OrderSend`.
- No `OrderModify`.
- No `OrderClose`.
- No `OrderCloseBy`.
- No pending deletion.
- No reset/reconstruction action.

### Inputs
The harness consumes the existing `ReplayTraceRecord` schema. A pair is loaded as:

`REFERENCE(Zeus) + OBSERVED(ZGOLD)`

The harness deliberately does not infer missing reference events.

### Alignment rule
Temporal alignment is explicit. The harness currently checks exact timestamp equality at the pair level; a future replay driver may supply a pre-aligned pair using the configured time tolerance.

This prevents an implicit assumption that two events belong to the same causal transaction burst.

### Comparison tolerances
The harness exposes explicit configuration for:

- time tolerance in seconds;
- price tolerance;
- lot tolerance.

Defaults are intentionally conservative and must be validated against the source trace before use in a formal pass.

### Divergence classes
Priority is causal and ordered:

- `D0_TEMPORAL_ALIGNMENT` — reference/observed pair is not temporally aligned.
- `D1_EVENT` — event type differs.
- `D2_DECISION` — decision/reason differs.
- `D3_PRICE_OR_GEOMETRY` — price differs beyond tolerance.
- `D4_LOT_OR_LIFECYCLE` — lot or lifecycle differs beyond tolerance.
- `D5_STATE_OR_EXPOSURE` — counts/lots of the directional state differ after the preceding dimensions match.

The first divergence is retained as the primary forensic anchor.

### Important limitation
`Reason` is currently used as the decision-level comparison field because the trace schema does not yet expose a separate normalized decision identifier. This is a comparison convention, not a claim that Zeus internally used a field named `Reason`.

### Current implementation
`ZGOLD/Debug/ReplayComparatorHarness.mqh`

The harness is passive and does not perform trade execution. It depends only on the existing trace record and comparator observer.

### Next stage
Stage 92 should connect the harness to an actual replay source and perform the first structured backtest observation pass. The initial pass must report the first divergence without changing any trading rule.
