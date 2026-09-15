# Stage 97.1 — Pending Trailing Gate Fix

## Finding
The first Strategy Tester run exposed a concrete implementation defect: pending-order distance family was re-derived from the *current* market-to-pending distance on every tick.

A pending order initially placed at FirstStep=1.60 naturally ceases to be exactly 1.60 away from the market as price moves. The observer therefore changed its family to `UNRESOLVED`, which blocked `PendingTrailingExecutionObserver` and prevented `OrderModify`.

## Correction
`PendingTrailingObserver` now persists the distance family per pending-ticket across ticks.

- First observation infers `FIRSTSTEP 1.60` or `MINDISTANCE 3.40` from the creation geometry.
- Subsequent market movement no longer invalidates the family.
- The current OOP-to-market delta remains observable, but is not used to erase the ticket's established family.
- New tickets are classified independently.

## Status
COMPROVADO as a software defect from code inspection and consistent with the observed symptom: initial bilateral pending structure existed, but trailing execution was blocked after market movement.

## Forensic boundary
This fix does **not** promote the unresolved 0.80 secondary expansion rule into a proven Zeus rule. That remains outside this fix.
