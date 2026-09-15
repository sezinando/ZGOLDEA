# ZGOLD — FORENSIC AUDIT STAGE 85
## Causal Reference Replay — Reference that generates the next pending order

**Status:** COMPLETED

**Scope:** forensic analysis only. No execution logic was changed and no rule was promoted to production.

### Objective

Stage 85 tests which observed object is the strongest causal reference for a new pending order, separating:

- last same-direction pending creation;
- last same-direction execution;
- last opposite-direction execution;
- structural continuity.

The purpose is to discriminate the `~0.80` and `~3.40` distance families without hard-coding the strongest hypothesis from Stage 84.

### Source

- `Comportamento EA.log`
- `Comportamento EA.csv`
- Zeus Gold Hedge V1.2, XAUUSD, Magic 1001
- `Point=0.01`

### Replay result

The replay parsed **227 pending-order creation events**.

For each creation, the nearest prior same-direction creation, same-direction execution and opposite-direction execution were resolved from the chronological event stream.

### Finding 1 — Last same-direction execution is the strongest direct reference candidate

Among creations with a prior same-direction execution:

- **113** creations were approximately `0.80` from the previous same-direction execution;
- **40** creations were approximately `3.40` from the previous same-direction execution;
- remaining events were outside those families.

This is substantially cleaner than using the previous same-direction *creation* as the reference.

### Finding 2 — Previous same-direction creation often fails to explain the new price

When the previous same-direction execution explains the creation with `~0.80` or `~3.40`, the immediately previous creation can be at a very different distance because that pending order may have been modified before execution.

This is direct evidence that **creation price history cannot be treated as equivalent to execution history**.

### Finding 3 — 0.80 family is strongly associated with repeated directional expansion

A representative sequence is:

- SELL #36 → 4530.80
- SELL #37 → 4531.63  (`+0.83`)
- SELL #38 → 4532.43  (`+0.80`)
- SELL #39 → 4533.26  (`+0.83`)

All are successive same-direction layers. This independently supports the Stage 84 conclusion that `0.80` is not simply a "first expansion" distance.

### Finding 4 — 3.40 family is also anchored to same-direction execution

Representative BUY sequence:

- BUY #12 → 4536.59
- BUY #15 → 4539.99  (`+3.40`)
- BUY #16 → 4543.39  (`+3.40`)
- BUY #18 → 4546.80  (`+3.41`)

The same-direction execution reference explains the new pending price with high consistency.

### Stage 85 conclusion

**STRONG BEHAVIORAL:** the last same-direction execution is currently the best direct causal reference candidate for the next layer price.

**NOT PROVEN:** that every creation is calculated exclusively from the last same-direction execution.

**NOT PROVEN:** the exact selector that chooses `0.80` versus `0.90` versus `3.40`.

**NOT PROVEN:** whether a persistent regime/flag modifies that selector.

### H3 status after Stage 85

Stage 84 H3 was:

> `0.80 = intra-structure` / `3.40 = inter-structure`

Stage 85 does **not** refute H3. It improves the model by adding a concrete causal candidate:

> `LastSameDirectionExecution -> DistanceSelector -> NewPendingPrice`

The role distinction remains a hypothesis because the exact transition condition between the two distance families is still unresolved.

### Important asymmetry observed

In the replayed sample:

- BUY creations with a prior same-direction execution: `0.80` family = 11, `3.40` family = 40;
- SELL creations with a prior same-direction execution: `0.80` family = 102, `3.40` family = 0.

This asymmetry is **observed**, but its cause is unresolved. It must not be promoted to a BUY/SELL-specific rule without a causal test.

### Negative controls

Using the last opposite-direction execution as the direct reference is materially less consistent:

- `3.40` family = 19;
- `0.80` family = 13;
- remaining events = outside these families.

Therefore opposite execution is a useful contextual signal, but it is currently weaker as a direct price anchor than same-direction execution.

### Formal Stage 85 model

```text
State(t)
  -> Reconcile
  -> Resolve LastSameDirectionExecution
  -> Collect Context:
       PreviousSamePending
       PreviousOppositeExecution
       PendingCompetitors
       DirectionalExtremes
       Reset/Basket boundary
  -> DistanceSelector [UNRESOLVED]
  -> CandidatePrice
  -> Geometry/Admissibility
  -> CREATE
```

### Safety rule

No new execution rule is enabled by this stage. The production EA remains observational.

### Next stage — Stage 86

Run a **causal transition matrix** over every creation and classify the state immediately before the creation into:

1. previous same-direction execution exists / does not exist;
2. previous same-direction pending exists / does not exist;
3. opposite execution immediately preceding exists / does not exist;
4. basket-close boundary;
5. global-reset boundary;
6. competing pending orders;
7. distance family observed (`0.80`, `0.90`, `1.60`, `3.40`, other).

The objective is to isolate the minimal state transition that predicts the distance family.
