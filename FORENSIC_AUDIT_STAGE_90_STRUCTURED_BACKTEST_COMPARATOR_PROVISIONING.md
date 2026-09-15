# FORENSIC AUDIT — STAGE 90
## Structured Backtest Comparator — Provisioning

### Objective
Provision the comparison layer that will later compare the reconstructed ZGOLD trace against the forensic Zeus reference trace.

### Safety boundary
This stage is observational only.
- No OrderSend.
- No OrderModify.
- No OrderClose.
- No OrderCloseBy.
- No pending deletion.
- No reset/reconstruction action.

### Comparison dimensions
The comparator tracks independent counters for:
1. Event match.
2. Decision match.
3. Price match.
4. Lot match.
5. Lifecycle match.

The first event divergence is retained as the primary forensic anchor.

### Status model
- `UNRESOLVED`: no comparable event sequence has been supplied yet.
- `MATCH`: all compared events matched.
- `DIVERGENCE`: at least one event diverged.

### Forensic rule
The comparator must prioritize the **first causal divergence** over final equity, final basket P/L, or aggregate performance. A later balance match cannot erase an earlier state-machine divergence.

### Current implementation
`ZGOLD/Debug/BacktestComparatorObserver.mqh`

This file is intentionally a passive accumulator. It does not know how the reference trace is generated and does not infer missing Zeus behavior. The reference/observed traces will be supplied by the subsequent replay harness.

### Next stage
Stage 91 should provision the replay harness that feeds timestamp-aligned reference and observed records into this comparator, including explicit tolerances for price and lot comparisons and divergence classes D0-D5.
