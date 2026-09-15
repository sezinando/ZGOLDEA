# FORENSIC AUDIT — STAGE 95 / 96 / 97 — FINAL BACKTEST GATE

## Status

STAGE 95: COMPLETED — Strategy Tester trace exporter provisioned.
STAGE 96: COMPLETED — replay temporal tolerance and causal comparison strengthened.
STAGE 97: COMPLETED — isolated execution adapter integrated into ZGOLD.mq4.

## Stage 95 — Trace

`ZGOLD/Debug/TesterTraceExporter.mqh` emits machine-readable `[ZGOLD][TRACE95]` records containing timestamp, event, ticket, direction, order type, lots, price, previous/reference price, distance family, exposure, exit fields, lifecycle and reason.

The exporter is observational and does not call trading APIs.

## Stage 96 — Replay comparator

`ReplayComparatorHarness.mqh` now evaluates temporal alignment using the configured second tolerance instead of requiring literal timestamp equality. Event comparison also validates direction and order type. Price comparison validates price, reference price and distance within configured tolerance. Divergence priority remains D0 through D5.

The `Reason` field remains a comparison convention for decision alignment; it is not claimed to be an original Zeus internal variable.

## Stage 97 — Execution

`ZGOLD/Engine/ExecutionEngine.mqh` is isolated from the observers and is responsible for:

- bilateral initial BUY STOP / SELL STOP creation;
- pending-order modification through the existing trailing decision observer;
- directional basket market close;
- compression closure of winner + two losses;
- global close cycle with `OrderCloseBy` and residual cleanup;
- pending cleanup and bilateral reconstruction;
- conservative post-execution opposing stop reconstruction at the proven 3.40 family.

The 0.80 same-direction secondary layer rule remains explicitly unresolved and is not invented in the execution engine.

## Execution profile

`ZGOLD.mq4` exposes:

- `EnableExecution = true`
- `ExecutionMode = 1`
- `SlippagePoints = 20`

`ExecutionMode=0` disables trading execution while preserving observation. Mode 1 is the controlled Strategy Tester reconstruction profile.

## Important forensic boundary

The execution profile is a reconstruction test harness, not a claim that every simultaneous Zeus exit priority or every secondary 0.80 layer condition is already proven. The previously unresolved Basket/Compression/Global simultaneous priority is not silently converted into a forensic fact; execution follows the explicit controlled test policy already documented in the controller.

## Environment limitation

No MetaTrader 4 Strategy Tester is available in this execution environment. Therefore no real Strategy Tester run, compiler result, or P/L result is claimed here. The repository is at the gate where the user can compile `ZGOLD.mq4` in MT4 and run the first controlled backtest.

## First backtest objective

The first run should be treated as an instrumentation/behavior validation pass. The decisive outputs are the tester Journal/TRACE95 records, order lifecycle, first divergence, and execution errors—not final net profit.
