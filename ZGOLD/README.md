# ZGOLD

Behavioral reconstruction of Zeus Gold Hedge V1.2.

## Fragment 01

Foundation only:

- EA entry points
- Runtime controller
- Market state
- State reconciler placeholder
- Incremental debug panel

**No trading logic is implemented in Fragment 01.**

## Debug Panel Principle

The panel displays runtime/behavioral state only. Configuration parameters remain in the MT4 `.set` file and are intentionally not duplicated in the panel.

## Incremental Development

Each new behavioral component will extend the panel with its current state, decision, action and result.

## Current State

- Core: implemented
- MarketState: implemented
- StateReconciler: observation-only foundation
- DebugPanel: implemented
- Order management: not implemented
- Layer Engine: not implemented
- Basket Engine: not implemented
- Compression Engine: not implemented
- Global Exit: not implemented
- CloseBy Engine: not implemented
- Reset Engine: not implemented
