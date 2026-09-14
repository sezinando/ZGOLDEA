# ZEUS GOLD HEDGE V1.2 — FORENSIC AUDIT CHECKPOINT — ETAPA 83

## Status
Checkpoint of the behavioral forensic reconstruction through Stage 83.

## Scope
This checkpoint records the current behavioral reconstruction only. It does not implement or assume source-code behavior that has not been demonstrated by the log/tick evidence.

## Consolidated Behavioral Core
- Initial/reconstructed bilateral structure: BUY STOP + SELL STOP, 0.01 each.
- FirstStep = 160 points = 1.60.
- Pending management is OOP modification, not conventional SL trailing; observed orders use SL=0 and TP=0.
- Normal observed trailing distances are FirstStep=1.60 and MinDistance=3.40.
- Step=0.80 is strongly supported as a geometric separation/admissibility parameter.
- Lot progression is independently directional:
  Lot(n)=NormalizeDouble(0.01*1.2^n + 0.01*n, 2), capped at 0.62.
- Directional basket target is N * StopProfit, with StopProfit=20; basket condition is basket profit >= target.
- Compression selects the winner plus the two worst losses and realizes positive/near-zero combined P/L in all observed cases.
- Global Exit condition supported by all observed global CloseBy bursts: TotalProfit >= 4.
- Global CloseBy pairs highest active BUY ticket with highest active SELL ticket; unequal lots produce a new residual ticket.
- Residuals are reconciled and can change direction across pairing generations.
- 4051 marks the end of valid CloseBy pairing; it does not itself close positions.
- Cleanup closes remaining market positions and deletes remaining pending orders; exact internal cleanup ordering is not universal/proven.
- Cleanup is followed by reset/rebuild of the bilateral 0.01/0.01 structure.
- BUY market close uses Bid; SELL market close uses Ask, proven by tick-level replay.
- A single EA-log timestamp may represent a transaction burst, not a single action.
- The system is a composite state machine rather than a mutually exclusive one-action-per-tick machine.

## Stage 80 Finding — Post-Basket Layer State
Strong evidence across observed directional basket closures supports:

BasketClose_D -> Directional Layer Reset -> Lot=0.01 -> FirstStep=1.60.

The earlier interpretation that BasketClose necessarily leads directly to 3.40 is rejected as a general rule.

## Stage 81–83 Finding — Expansion Entry Classification
The expansion distance cannot be reduced to Direction, Count, Lot, or LastTicket alone.

The current behavioral model is:

State -> LayerState -> Reference Structure -> Candidate -> Geometry Constraint -> Admissibility -> Order Creation.

The evidence indicates that 0.80 and 3.40 represent distinct geometric behaviors, but the exact discriminator between them remains unresolved.

## Stage 83 — Pre-Creation State Reconstruction
### Proven / Strong
- Layer creation is state-dependent.
- Last-order price is not a sufficient universal reference for layer creation.
- 0.80 and 3.40 both occur in real layer sequences.
- Same direction can use different distances in different structural contexts.
- A reference structure/extrema component is required before the geometry solver.

### Unresolved
- Exact Reference Structure Resolver.
- Exact condition selecting 0.80 versus 3.40.
- Activation of Money.
- Activation of TwoMinDistance.
- Activation of TwoStep.
- NextTime behavior.
- Exact rare same-timestamp conflict priority.

## Current Layer Architecture

STATE RECONCILIATION
  -> EXPOSURE STATE
  -> LAYER STATE
  -> REFERENCE STRUCTURE RESOLVER   [current investigation point]
  -> CANDIDATE BUILDER
  -> GEOMETRY SOLVER
       -> 0.80 / 3.40
  -> LAYER ADMISSIBILITY
  -> ORDER CREATION

## Explicitly Refuted / Forbidden Assumptions
- Fixed price grid.
- Distance determined solely by direction.
- Distance determined solely by Count.
- Distance determined solely by Lot.
- Universal BasketClose -> 3.40.
- OneActionPerTick as a literal behavioral rule.
- CloseAll=4 interpreted as four positions.
- MaxLossCloseAll=100 as universal observed global trigger.
- Residual volume being discarded.
- Compression as combinatorial profit optimization.
- SL trailing as the observed pending-management mechanism.

## Reconstruction Readiness
The majority of the risk/exit/state machinery is sufficiently characterized for a behavioral Oracle design. The Layer Creation Engine should not yet be considered fully reconstructed because the reference-selection and 0.80/3.40 discrimination remain open.

## Next Stage
ETAPA 84 — Reference Structure Resolver.

Objective:
Determine which structural price/reference the Zeus uses to construct each new layer candidate, testing LastLayer, directional extrema, opposite extrema, pending references, and composite references without assuming the result in advance.
