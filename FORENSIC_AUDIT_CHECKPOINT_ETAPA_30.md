# ZGOLDEA — Zeus Gold Hedge V1.2
## FORENSIC AUDIT CHECKPOINT — ETAPAS 01–30

**Checkpoint:** Baseline forensic reconstruction through Stage 30  
**Scope:** Observed behavior of Zeus Gold Hedge V1.2 on XAUUSD  
**Status:** Investigation only — no implementation architecture is authorized by this document  
**Principle:** Observed behavior takes precedence over assumptions and over code from related/public EAs.

---

## 0. FORENSIC RULE

This document freezes the behavioral knowledge reconstructed from the Zeus Gold Hedge V1.2 test artifacts before proceeding to Stage 31.

The investigation intentionally started from zero and discarded assumptions from previous engines/architectures. The public implementation of the same EA family is corroborative evidence only; it is NOT treated as proof of the exact Zeus V1.2 source code.

Classification:
- **COMPROVADO** — directly demonstrated by Zeus log/CSV behavior.
- **HIPÓTESE FORTE / CORROBORADO** — strongly supported by repeated observations and/or family-source correspondence, but not uniquely proven as source code.
- **NÃO DETERMINADO** — insufficient evidence to identify the exact implementation.
- **REFUTADO** — contradicted by observed behavior.

---

# 1. INPUTS OBSERVED

The Zeus V1.2 test reported:

- Magic = 1001
- StopProfit = 20
- StopLoss = 0
- lot = 0.01
- K_Lot = 1.2
- DigitsLot = 2
- CloseAll = 4
- PlusLot = 0.01
- Maxlot = 0.62
- MaxSpread = 100
- NextTime = 0
- FirstStep = 160 points = 1.60
- MinDistance = 340 points = 3.40
- TwoMinDistance = 80 points = 0.80
- StepTrallOrders = 50 points = 0.50
- Step = 80 points = 0.80
- TwoStep = 90 points = 0.90
- MaxLoss = 100000
- MaxLossCloseAll = 100
- Totals = 2000
- Leverage = 100

Source evidence: Zeus log input line and initial bilateral orders.

---

# 2. ETAPA 01 — ANATOMIA DA ENTRADA

## COMPROVADO

1. Initial bilateral structure: one BUY STOP and one SELL STOP, both 0.01.
2. Initial distance is FirstStep = 1.60.
3. Pending orders are dynamic objects: CREATE → PENDING → MODIFY → EXECUTE or DELETE.
4. Pending trailing changes OOP (entry price), not conventional SL trailing; observed SL/TP are zero.
5. Execution does not terminate the mechanism; new pending orders are created.
6. Bilateral pending structure can persist while a directional basket is active.
7. Lot size is dynamic.
8. Basket closures can close only one direction.
9. A separate OrderCloseBy hedge/compensation mechanism exists.
10. Creation price may differ from execution price because the pending OOP can be modified.
11. Certain global closures reconstruct the bilateral pending structure.

---

# 3. ETAPA 02 — MATEMÁTICA DO TRAILING DAS PENDENTES

Analysis of all observed OOP modifications established two exact geometries.

### BUY

FirstStep regime:

`OOP = Ask + 1.60`

MinDistance regime:

`OOP = Ask + 3.40`

### SELL

FirstStep regime:

`OOP = Bid - 1.60`

MinDistance regime:

`OOP = Bid - 3.40`

## COMPROVADO

- No observed modification used 0.80 or 0.90 as the direct trailing offset.
- StepTrallOrders = 50 points is strongly supported by cross-correlation with tick data: consecutive same-ticket reference-price movement was never below approximately 0.50.
- The pending OOP is recalculated from current Bid/Ask using the ticket's active distance regime.

## NÃO DETERMINADO

Exact state transition between FirstStep and MinDistance for every creation context.

---

# 4. ETAPA 03 — MATEMÁTICA DO LOTE

The exact directional lot formula was reconstructed:

`Lot(n) = NormalizeDouble(lot * K_Lot^n + n * PlusLot, DigitsLot)`

then capped at Maxlot.

With the observed inputs:

n=0 .01  
n=1 .02  
n=2 .03  
n=3 .05  
n=4 .06  
n=5 .07  
n=6 .09  
n=7 .11  
n=8 .12  
n=9 .14  
n=10 .16  
n=11 .18  
n=12 .21  
n=13 .24  
n=14 .27  
n=15 .30  
n=16 .34  
n=17 .39  
n=18 .45  
n=19 .51  
n=20 .58  
n=21 .62 (cap)

BUY and SELL progressions are independent and reset after the corresponding directional basket is zeroed.

Status: **COMPROVADO**.

---

# 5. ETAPA 04 — FORMAÇÃO DA CESTA / CAMADAS

## COMPROVADO

- First directional order uses FirstStep.
- Subsequent primary geometry uses MinDistance = 3.40.
- Step = 0.80 participates in layer admissibility/spacing.
- Pending orders continue to trail after creation.

## HIPÓTESE FORTE / NÃO DETERMINADO

- Extrema-based layer admissibility.
- Secondary-state geometry using TwoMinDistance and TwoStep.
- Exact activation of the secondary state, potentially related to Money/total P/L in the public family implementation.

Do not implement secondary geometry as exact Zeus behavior until independently validated.

---

# 6. ETAPA 05 — MATEMÁTICA DO FECHAMENTO DA CESTA

For BUY:

`Profit = (Close - Open) * Lot * 100`

For SELL:

`Profit = (Open - Close) * Lot * 100`

Equivalent execution-price form naturally incorporates spread.

Basket target:

`Target_D = N_D * StopProfit`

Therefore, with StopProfit=20:

`BasketTarget = number_of_directional_positions * 20`

Observed examples include 2-position baskets near 40, 4-position baskets near 80 and 5-position baskets near 100.

Actual reported profit may be slightly above the mathematical threshold because the check occurs against live price.

Status: **COMPROVADO**.

CloseAll=4 is NOT the number of positions.

---

# 7. ETAPA 06 — FECHAMENTO E RECONSTRUÇÃO PÓS-CESTA

Normal directional basket close:

1. Close all positions of that direction.
2. Directional count resets.
3. The opposite side may remain active.
4. New pending orders can be created in the continuing cycle.

Global reset is different:

1. Pair opposing positions through OrderCloseBy.
2. Process residual volume.
3. When no valid pair remains, 4051 occurs.
4. Close remaining residual positions individually.
5. Delete old pending orders.
6. Rebuild BUY STOP 0.01 and SELL STOP 0.01.
7. Resume trailing/expansion.

Status: **COMPROVADO**.

---

# 8. ETAPA 07 — ORDERCLOSEBY / RESIDUALS

The residual volume created by OrderCloseBy appears as a NEW ticket and becomes the next participant in the pairing chain.

For lots A and B:

- equal → both compensated;
- A > B → B closes, A residual becomes a new ticket;
- B > A → A closes, B residual becomes a new ticket.

This explains apparent "phantom" tickets.

Repeated chains demonstrate that the residual ticket participates immediately in the next pairing.

Status: **COMPROVADO**.

---

# 9. ETAPA 08 — SELEÇÃO DOS PARES

Across 56 `order #X was closed by order #Y` lines grouped into 10 global events, the active BUY and SELL participants consistently follow highest-ticket/LIFO behavior.

Behavioral rule:

`Partner(side) = highest active ticket of opposite direction`

When residual volume generates a new ticket, that ticket becomes the newest participant.

Implementation detail such as the exact scanning loop remains a strong hypothesis, but the observed selection behavior is proven.

---

# 10. ETAPA 09 — CLOSEALL

The principal observed CloseAll condition is:

`Profit_BUY + Profit_SELL >= CloseAll`

with CloseAll=4.

The first nine normal global events strongly support this threshold.

Important exception: the 11:55 event is a protective global neutralization path with negative floating total, so `total >= 4` is the main path, not a universal explanation of every global liquidation.

MaxLossCloseAll=100 is NOT proven to be a direct `loss <= -100` trigger.

Status:
- main +4 path: **VERY STRONG / CORROBORATED**
- universal CloseAll condition: **NOT PROVEN**

---

# 11. ETAPA 10 — P/L

The Zeus uses ordinary XAUUSD price × lot economics.

BUY:

`Profit = (Bid_close - Ask_open) * Lot * 100`

SELL:

`Profit = (Bid_open - Ask_close) * Lot * 100`

This is behaviorally equivalent to summing order profit with transaction components, as corroborated by the family implementation.

Status: **COMPROVADO BEHAVIORALLY**.

---

# 12. ETAPAS 11–14 — COMPRESSÃO / PROTEÇÃO

Observed selective compression has a deterministic selection signature.

For direction D:

`Winner_D = argmax(OrderProfit())`

`Loss1, Loss2 = two lowest OrderProfit() positions`

Close set:

`{Winner, Loss1, Loss2}`

The combined realized P/L is always slightly positive or approximately zero in all 11 observed compression events.

This is not a generic "close three" operation. It is inventory/risk compression.

Status: **COMPROVADO**.

---

# 13. ETAPA 15 — ESPECIFICAÇÃO COMPORTAMENTAL CONSOLIDADA

High-level states reconstructed:

S0 Initialization  
S1 Dynamic pending  
S2 Execution/expansion  
S3 Layer formation  
S4 Basket close  
S5 Selective compression  
S6 Protection trigger  
S7 CloseAll  
S8 OrderCloseBy  
S9 4051  
S10 Cleanup  
S11 Reset

Exact secondary spacing state and some protection parameters remain open.

---

# 14. ETAPA 16 — MÁQUINA DE ESTADOS

Conceptual machine:

`RESET → BILATERAL → EXPANSÃO → {BASKET / COMPRESSÃO / CLOSEALL} → CLEANUP/RESET`

Trailing and pending expansion are continuing mechanisms rather than terminal states.

---

# 15. ETAPA 17 — FALSIFICAÇÃO

Validated:

- Basket target N×20: no observed counterexample.
- Lot formula: no incompatible creation sequence.
- OOP geometry: all observed modifications explained by 1.60/3.40 regimes.
- Highest-ticket OrderCloseBy selection: repeated confirmation.
- Residual → new ticket: repeated confirmation.
- 4051 marks end of valid pairing.
- Bilateral .01/.01 rebuild: repeated confirmation.
- Winner + two worst losses: repeated confirmation.
- Compression near-zero positive: repeated confirmation.

Refuted:

- CloseAll=4 as number of positions.
- MaxLossCloseAll=100 as a simple universal loss trigger.
- Global combinatorial optimization for compression.
- Maximization of lots removed as compression objective.
- Maximization of realized profit as compression objective.

---

# 16. ETAPAS 18–20 — TEMPORAL RECONSTRUCTION / PROTECTION

Selective compression occurs during expansion and does not inherently cause reset.

Examples:

- 03:17:40 and 03:19:38: compressions followed by continued expansion.
- 11:00 and 11:45: repeated BUY compressions.
- 11:54:40 and 11:55:36: repeated SELL compressions followed two seconds later by global neutralization.

The apparent 11:45 counterexample to the 3×WinnerLot condition was caused by stale state from a previous reset and was formally corrected.

---

# 17. ETAPAS 21–23 — EXPOSURE LEDGER / FAMILY CORROBORATION

The reliable state reconstruction must respect reset boundaries and cannot infer synthetic residual tickets simply as the next maximum ticket number.

Family-source corroboration strongly supports the exposure condition:

`Lots_D > Lots_Opp + 3 * WinnerLot`

with directional count > 3.

The family source also contains P/L-distribution logic and global protection branches, but it is not treated as exact Zeus source code.

---

# 18. ETAPA 24 — DISTRIBUIÇÃO DE P/L

The initial generic distribution hypotheses were tested and rejected when they did not explain the exact observed trio selection.

Important distinction:

1. Why compress? = eligibility/trigger.
2. What to compress? = deterministic ranking.

The observed trio is NOT selected by global combinatorial optimization.

---

# 19. ETAPA 25 / 25.12 — CONTROLES NEGATIVOS

At 11:08:52 the exposure condition was already true:

`BUY=0.25, SELL=0.06, WinnerLot=0.06`

and:

`0.25 > 0.06 + 3×0.06`

Yet compression did not occur.

This proves exposure imbalance is necessary but not sufficient.

Immediately before observed compression, the selected trio's combined P/L was negative; at the compression second it became positive.

---

# 20. ETAPA 26 — MATRIZ DE ELEGIBILIDADE

All 11 observed compression events satisfy:

`Lots_D > Lots_Opp + 3×WinnerLot`

and:

`N_D > 3`

and the selected trio is positive/near-zero.

Second-by-second negative controls showed the trio metric remained negative before the actual compression second.

Best behavioral model:

`Exposure imbalance AND count > 3 AND trio financing capacity > 0 → compression`

---

# 21. ETAPA 27 — OBJETIVO ECONÔMICO DA COMPRESSÃO

Exhaustive 3-position combination testing demonstrated that Zeus does NOT globally optimize for:

- maximum lots removed;
- maximum realized profit;
- maximum feasible exposure reduction.

Instead, Zeus uses deterministic ranking:

`Winner = maximum P/L`

`Loss1/Loss2 = two minimum P/L`

The economic effect is inventory reduction at approximately zero realized cost.

Observed exposure reductions ranged materially, often 25–75% in ordinary baskets, while large baskets can be compressed incrementally.

This establishes compression as an **inventory/risk compression mechanism**, not a profit-maximization routine.

---

# 22. ETAPA 28 — FUNÇÃO DE ELEGIBILIDADE COMPORTAMENTAL

The best behavioral eligibility function was reconstructed as:

For direction D:

`Eligible_D = DominantExposure_D AND Count_D > 3 AND Winner_D > 0 AND Trio_D >= 0`

with:

`DominantExposure_D = Lots_D > Lots_Opp + 3×WinnerLot_D`

and:

`Trio_D = Winner_D + WorstLoss1_D + WorstLoss2_D`

The Winner>0 condition is effectively implied by positive trio financing capacity but remains conceptually explicit.

---

# 23. ETAPA 29 — RECONSTRUÇÃO DE do32

The family implementation provides the strongest corroboration for the economic metric.

The distribution function separates positive and negative OrderProfit values, sorts them, and sums the requested top elements.

The CloseBuySell logic uses one positive element and two negative elements, producing the behavioral metric:

`do32_D = Winner_D - |WorstLoss1_D| - |WorstLoss2_D|`

Equivalent form:

`do32_D = Winner_D + WorstLoss1_D + WorstLoss2_D`

where WorstLoss values are negative P/L values.

Therefore:

`do32_D > 0`

means:

`Winner_D > |WorstLoss1_D| + |WorstLoss2_D|`

Economic interpretation:

**The largest winner can finance the two largest losers.**

Observed examples:

- 03:17:40 → +0.88
- 03:19:38 → +0.27
- 11:45:37 → +0.08
- 14:02:39 → +0.35
- 16:39:02 → +2.70
- 18:16:01 → +0.11
- 20:07:05 → +0.11
- 05:39:36 → +0.01
- 11:54:40 → +0.66
- 11:55:36 → +0.13

This strongly explains the observed compression moments.

Important caveat: `do32`, `lizong_10`, `do23`, etc. are names from the corroborative family implementation. They are NOT claimed to be literal variable/function names inside the Zeus V1.2 binary/source.

---

# 24. ETAPA 30 — EXECUTION PRIORITY

Stage 30 reconstructed the likely execution hierarchy between competing exit mechanisms.

## Priority 1 — Basket Target

Directional basket realization:

`Profit_D >= N_D × StopProfit`

This closes the complete direction.

Status: **VERY STRONG / COMPROVADO BEHAVIORALLY**.

## Priority 2 — Compression

Eligibility:

`Lots_D > Lots_Opp + 3×WinnerLot`

`Count_D > 3`

`do32_D > 0`

Action:

close Winner + two worst losses.

Compression does not inherently reset the grid.

Status: **VERY STRONG**.

## Priority 3 — CloseAll / OrderCloseBy

Main normal path:

`Profit_BUY + Profit_SELL >= CloseAll`

then bilateral compensation through OrderCloseBy.

The 11:54/11:55 sequence demonstrates that compression occurs before global neutralization when both mechanisms are approaching eligibility.

Status: **VERY STRONG**.

## Priority 4 — Cleanup

After OrderCloseBy pairing is exhausted / 4051 occurs:

- close residual positions;
- delete pending orders;
- clean remaining exposure.

Status: **COMPROVADO**.

## Priority 5 — Reset

Rebuild:

- BUY STOP 0.01
- SELL STOP 0.01

and resume the bilateral engine.

Status: **COMPROVADO**.

---

# 25. EXECUTION PRIORITY MATRIX

| Priority | Engine | Behavioral role | Status |
|---|---|---|---|
| 1 | Basket Target | Full directional realization | Very strong |
| 2 | Compression / do32 | Reduce directional inventory near-zero cost | Very strong |
| 3 | CloseAll / OrderCloseBy | Global bilateral neutralization | Very strong |
| 4 | Cleanup | Residual liquidation and pending deletion | Proven |
| 5 | Reset | Rebuild bilateral .01/.01 structure | Proven |

The exact source-code control-flow statement is not proven, but the observed temporal ordering strongly supports this hierarchy.

---

# 26. EXECUTION LOCK — CURRENT HYPOTHESIS

The absence of observed same-tick execution of competing terminal routines suggests a possible one-action execution lock:

`OnTick → first eligible terminal action → return`

Possible behavioral structure:

1. evaluate Basket;
2. if executed, stop current action cycle;
3. otherwise evaluate Compression;
4. if executed, stop current action cycle;
5. otherwise evaluate CloseAll;
6. then cleanup/reset as applicable.

Status: **HIPÓTESE FORTE**, not literal source-code proof.

---

# 27. CURRENT ZEUS BEHAVIORAL MODEL

```text
ON TICK
  │
  ├─ Update market / P&L / exposure
  │
  ├─ Update pending OOP trailing
  │
  ▼
BASKET TARGET?
  │ YES → close directional basket → continue
  │ NO
  ▼
COMPRESSION ELIGIBLE?
  │ YES → close Winner + 2 Worst Losses → continue
  │ NO
  ▼
CLOSEALL / GLOBAL PROTECTION?
  │ YES → OrderCloseBy
  │         ↓
  │       residuals
  │         ↓
  │       4051
  │         ↓
  │       cleanup
  │         ↓
  │       reset
  │ NO
  ▼
EXPANSION / PENDING MANAGEMENT
```

This diagram is a behavioral reconstruction, not implementation code.

---

# 28. WHAT IS NOW SAFE TO CONSIDER ESTABLISHED

### 🟢 Strongly established

- bilateral initial pending structure;
- FirstStep geometry;
- MinDistance trailing geometry;
- StepTrallOrders behavior;
- directional lot progression;
- basket target N×StopProfit;
- directional basket closure;
- selective compression selection;
- compression's near-zero realized P/L;
- exposure reduction objective;
- OrderCloseBy pairing behavior;
- residual-ticket mechanism;
- highest-ticket/LIFO pairing;
- 4051 termination of pairing;
- cleanup/reset sequence;
- `do32` behavioral meaning;
- compression eligibility as exposure + distribution conditions;
- likely execution priority.

### 🟡 Still open

- exact TwoMinDistance activation;
- exact TwoStep activation;
- exact `Money` state logic in Zeus V1.2;
- exact `MaxLoss` role;
- exact `MaxLossCloseAll` role;
- exact universal CloseAll/protective boolean;
- literal source implementation of `do32` in Zeus V1.2;
- exact same-tick priority/control-flow mechanism;
- exact interaction of all conditions when multiple routines become true on the identical tick.

### 🔴 Refuted hypotheses

- CloseAll=4 means four positions;
- MaxLossCloseAll=100 means simple `loss <= -100` trigger;
- compression maximizes realized profit;
- compression maximizes lots removed;
- compression performs global combinatorial optimization;
- exposure imbalance alone is sufficient for compression.

---

# 29. NEXT INVESTIGATION

## ETAPA 31 — RECONSTRUÇÃO DA MÁQUINA CENTRAL DO ZEUS (`OnTick`)

The next stage should integrate the individually reconstructed mechanisms into a single chronological behavioral scheduler.

Objectives:

1. reconstruct the probable order of internal calculations;
2. identify which variables must be refreshed before each decision;
3. integrate Basket, Compression, CloseAll, Trailing and Expansion;
4. reconstruct state transitions around reset boundaries;
5. distinguish proven behavior from inferred control flow;
6. produce the behavioral blueprint of the central Zeus engine before any implementation is attempted.

**No new implementation should be authorized solely from this checkpoint.**

---

# 30. CHECKPOINT INTEGRITY

This document is the official forensic baseline through Stage 30.

Any later reconstruction that contradicts this document must explicitly identify:

- the contradiction;
- the evidence causing the revision;
- whether the prior rule is weakened, refuted, or merely reclassified;
- the new confidence level.

This prevents silent drift of the reverse-engineering model.
