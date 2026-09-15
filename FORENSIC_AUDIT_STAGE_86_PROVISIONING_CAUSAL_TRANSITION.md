# ZGOLD — STAGE 86 PROVISIONING
## Causal Transition Observer

**Status:** PROVISIONED — observational only

### Objective
Prepare the reconstruction for the next forensic/backtest pass without promoting the unresolved `~0.80` vs `~3.40` selector into trading logic.

### Provisioned component
`ZGOLD/Engine/CausalTransitionObserver.mqh`

The observer maintains, across the runtime lifecycle:

- last BUY execution ticket and price;
- last SELL execution ticket and price;
- distance from each visible directional pending candidate to the latest same-direction execution;
- classification into observed distance families (`~0.80`, `~0.90`, `~1.60`, `~3.40`, `OTHER`).

### Evidence discipline

The observer is explicitly non-executing. It does not create, modify, delete or close orders.

The family classifier is an **instrumentation tolerance**, not a reconstructed Zeus rule. It exists only to make the next replay/backtest trace easier to compare.

### Current forensic model

`LastSameDirectionExecution -> candidate distance -> observed family`

remains the strongest direct causal candidate from Stage 85.

Still unresolved:

- exact selector between `~0.80`, `~0.90` and `~3.40`;
- role of previous same-direction pending;
- effect of opposite execution;
- basket/reset boundary effects;
- persistent versus instantaneous regime state;
- exact priority among simultaneous creation/exit conditions.

### Next operation

Compile the current observer build first. Then execute a controlled MT4 backtest using the reconstructed baseline and compare:

1. lifecycle transitions;
2. pending modifications;
3. pending executions;
4. layer creation timing and price;
5. lot sequence;
6. basket exits;
7. compression candidates;
8. global CloseBy cycles;
9. reset/reconstruction events;
10. causal observer output versus the original forensic trace.

### Acceptance rule

A behavior is promoted from hypothesis to implementation only when the backtest trace reproduces it consistently and no contradictory observed case remains unexplained.

No production trading logic is enabled by Stage 86 provisioning.
