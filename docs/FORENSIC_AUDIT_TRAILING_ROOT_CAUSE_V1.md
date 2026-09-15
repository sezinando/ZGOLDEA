# ZGOLD — Forensic Audit: Pending Trailing Root Cause V1

## Status

**Confirmed against current repository implementation on 2026-09-15.**

## Root-cause chain

The pending trailing pipeline was blocked by four coupled defects:

1. `ZGOLD.mq4` default inputs were not aligned with the validated forensic baseline: `FirstStep=80`, `TwoStep=120`, `TwoMinDistance=90` instead of `160`, `90`, `80` points.
2. `PendingTrailingObserver` classified distance using hard-coded geometry instead of `ZGoldParams`.
3. `PendingTrailingDecisionObserver` refused to trigger when the distance family was unresolved.
4. `PendingTrailingExecutionObserver` compared family strings using a different numeric representation and also hard-coded the candidate distances.

## Corrective principle

Distance families are now canonical symbolic classes (`FIRSTSTEP`, `MINDISTANCE`) and their numeric geometry is always obtained from `ZGoldParams`. This removes formatting-dependent string comparisons and keeps runtime inputs authoritative.

`StepTrallOrders` is also used through `ZGoldParams` rather than a hard-coded `0.50` price distance.

## Safety boundary

This correction changes the trailing decision/execution pipeline only. It does not introduce a new expansion rule or resolve any still-unproven Zeus layer-selection behavior.

## Expected behavior after correction

`Pending exists -> classify current OOP distance -> trailing reference moves by StepTrallOrders -> TRAIL decision -> candidate price -> OrderModify`.

The initial structure remains governed by `FirstStep`; with the validated baseline it is 160 points (1.60 price on XAUUSD with Point=0.01).
