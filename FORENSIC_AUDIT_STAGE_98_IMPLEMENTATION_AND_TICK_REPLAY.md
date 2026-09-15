# FORENSIC AUDIT — STAGE 98

## Objective
Advance the ZGOLD reconstruction while keeping unresolved Zeus rules out of the execution core, expose the recovered parameters for controlled tester calibration, and validate the supplied XAUUSD tick/Zeus artifact independently.

## Implementation delivered

### 1. Runtime parameterization
`ZGOLD.mq4` now exposes the recovered Zeus parameters as tester inputs and calls `ZGoldParams::Configure()` at initialization.

Distance inputs remain in **MT4 points** and are converted to price using `Point` inside `ZGoldParams`.

This prevents the previous hard-coded 1.60/3.40/0.50 geometry from blocking future isolated parameter tests.

### 2. Directional lot state
`ExecutionEngine` now maintains independent BUY/SELL lot levels. The recovered lot formula remains:

`NormalizeDouble(lot * K_Lot^n + n * PlusLot, DigitsLot)`

with `Maxlot` cap.

The initial bilateral pair uses level 0 on both sides. Successful new pending creation advances only its own directional level.

### 3. Directional basket reset
After a directional basket close, the corresponding lot state is reset to level 0. If the closed direction no longer has a pending order, a conservative reset pending is rebuilt using the proven `MinDistance` family.

This models the observed post-basket return to base lot without introducing the unresolved `Step/TwoStep/TwoMinDistance` layer selector.

### 4. Global reset
The global cleanup path resets both directional lot levels before reconstructing the bilateral initial structure.

## Tick/Zeus validation performed

Artifact:
`EAGOLD_TICKS_XAUUSD 1-06-2026 T2.csv`

- 416,289 ticks
- XAUUSD
- Point = 0.01
- 2 digits
- 2026-06-01 01:00:00 → 2026-06-02 12:17:31
- spread in the supplied first tick = 2 points / 0.02 price

Exact Zeus V1.2 run selected from the supplied log by the parameter line containing `FirstStep=80`.

### Zeus run inventory

- CREATE: 264
- MODIFY: 500
- EXECUTE: 255
- normal CLOSE lines: 195
- DELETE lines: 8

### Confirmed geometry

Initial market:
- Bid 4535.56
- Ask 4535.58

Initial pending orders:
- BUY STOP 4536.38 = Ask + 0.80 = FirstStep(80 points)
- SELL STOP 4534.76 = Bid - 0.80 = FirstStep(80 points)

**Status: COMPROVADO.**

The same run also contains the robust MinDistance family around 3.40 price units. This confirms that reducing FirstStep from 160 to 80 did not collapse MinDistance into the same mechanism.

### Confirmed trailing threshold

Across consecutive same-ticket MODIFY transitions:
- 415 transitions
- minimum absolute movement: 0.51 price
- no transition below 0.50 price

With `StepTrallOrders=50` points and Point=0.01, this is consistent with the 0.50 price threshold.

**Status: COMPROVADO.**

### Confirmed lot sequence

The supplied Zeus CREATE events use only values present in the recovered formula sequence:

`0.01, 0.02, 0.03, 0.05, 0.06, 0.07, 0.09, 0.11, 0.12, 0.14, 0.16, 0.18, 0.21, 0.24, 0.27, 0.30, 0.34, 0.39, 0.45, 0.51, 0.58, 0.62`

**Status: COMPROVADO for the formula family.**

The exact state variable/counter semantics that select `n` in every branch remain an implementation-level reconstruction problem.

### Confirmed dynamic expansion

The exact Zeus run contains post-execution creations such as:
- BUY 0.01 → SELL STOP 0.02
- SELL 0.02 → BUY STOP 0.02

and later dynamic directional levels including 0.03, 0.05, 0.06, 0.07, etc.

**Status: COMPROVADO.**

The implementation therefore no longer uses the executed lot blindly for every expansion.

### TwoStep

The test changed `TwoStep` to 120 points, but no universal direct 1.20-price creation family was found.

**Status: REFUTADO as a simple universal `distance = TwoStep * Point` rule.**

`TwoStep` and `TwoMinDistance` remain available as inputs but are intentionally not hard-coded as direct expansion distances.

### Important unresolved behavior

Still not promoted to the execution core:

1. Exact selector between the 0.80/0.90 family and the 3.40 family.
2. Exact causal reference used by every new layer.
3. Exact priority among Basket, Compression and Global when multiple gates are simultaneously eligible.
4. Exact semantics of MaxLoss, MaxLossCloseAll and Totals.
5. Exact state semantics behind the directional lot index in every reset/partial-close branch.

## Validation boundary

This environment does not contain a MetaTrader 4 Strategy Tester/MetaEditor runtime. Therefore this stage does **not** claim that the modified `ZGOLD.mq4` was compiled or executed inside MT4.

What was executed autonomously:
- source-level implementation changes in the repository;
- deterministic inspection of the supplied 416,289-tick artifact;
- deterministic parsing and validation of the exact Zeus V1.2 tester segment;
- independent checks of geometry, trailing threshold, and lot-family invariants.

A real MT4 execution/backtest of the new ZGOLD build requires an MT4 runtime. The repository is prepared for that controlled tester run.

## Decision

**IMPLEMENTED:** configurable recovered parameters, point-based geometry, directional lot state, directional basket reset, global lot reset.

**VALIDATED:** FirstStep=80 initial geometry, MinDistance family existence, StepTrallOrders=50 threshold, recovered lot formula family, dynamic post-execution expansion.

**NOT IMPLEMENTED:** unresolved layer selector and unresolved exit-priority rules.

## Next calibration target

The cleanest next Zeus experiment remains an isolated `Step` test while holding the other parameters fixed. This is required before promoting `Step` from strong hypothesis to implementation rule.
