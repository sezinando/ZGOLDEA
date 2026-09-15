# ZGOLD — FORENSIC AUDIT STAGE 84
## Reference Structure Resolver / Exit Gate Corrections

### Objective
Prevent silent architectural assumptions while testing the unresolved discriminator between the observed 0.80 and 3.40 layer-distance families.

### Implemented corrections
1. Exit gates are now exposed independently:
   - BUY basket eligible
   - SELL basket eligible
   - BUY compression eligible
   - SELL compression eligible
   - Global exit eligible
2. The controller no longer silently reports Basket > Compression > Global. Multiple eligible gates are reported as `CONFLICT_UNRESOLVED` until proven by replay.
3. BUY-vs-SELL compression is no longer resolved by an undocumented `do32` tie-break in the decision layer.
4. `winner > 0` is not treated as part of the core eligibility model; `do32 > 0` remains the eligibility gate.
5. Exit capacity now emits a warning when the observer reaches its 64-position implementation cap.
6. Reconstructed parameters are centralized in `ZGOLD/Config/ZGoldParams.mqh` with a clear distinction between reconstructed values and implementation-only values.
7. Basket and geometry engines consume the centralized configuration instead of scattering reconstructed literals.

### Stage 84 hypotheses
**H1 — Extreme-based:** a candidate beyond the established directional extreme maps to the 0.80 Step family; otherwise 3.40 MinDistance.

**H2 — Count-based:** first expansion uses 0.80 and later expansions use 3.40. Expected to be vulnerable to same-direction counterexamples.

**H3 — Structural role:** 0.80 is intra-structure spacing; 3.40 is inter-structure spacing.

**H4 — Persistent regime:** an unresolved persistent state switches between the two geometry families.

### Current implementation status
The new `ReferenceStructureResolver` records directional extrema, current pending candidates, and an explicit H1 prediction. H2/H3/H4 remain `NOT TESTABLE FROM CURRENT SNAPSHOT` because they require event-level replay across layer-creation transactions.

### Methodology for the next forensic replay
For every observed layer-creation event, record:
- timestamp
- direction
- distance family (0.80 / 3.40)
- candidate price
- last same-direction execution/layer ticket
- active count
- directional extreme since reset/basket closure

Then run H1-H4 independently and search for explicit counterexamples before promoting any hypothesis.

### Classification discipline
No unresolved hypothesis is promoted to `COMPROVADO` by implementation convenience. Until the replay provides discrimination, the resolver remains explicitly `UNRESOLVED`.
