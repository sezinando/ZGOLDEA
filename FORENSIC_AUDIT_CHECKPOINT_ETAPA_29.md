# ZGOLDEA — Zeus Gold Hedge V1.2
## FORENSIC AUDIT CHECKPOINT — ETAPAS 01–29

**Checkpoint:** Baseline forensic reconstruction through Stage 29  
**Scope:** Observed behavior of Zeus Gold Hedge V1.2 on XAUUSD  
**Status:** Investigation only — no implementation architecture is authorized by this document  
**Principle:** Observed behavior takes precedence over assumptions and over code from related/public EAs.

---

## 0. PURPOSE AND FORENSIC RULE

This document freezes the behavioral knowledge reconstructed from the Zeus Gold Hedge V1.2 test artifacts before proceeding to Stage 30.

The investigation started from zero and intentionally discarded assumptions from previous engines/architectures. The public implementation of the same EA family was used only as corroborative evidence; it is **not** treated as proof of the exact Zeus V1.2 source code.

Every conclusion is classified as:

- **COMPROVADO** — directly demonstrated by Zeus log/CSV behavior.
- **HIPÓTESE FORTE / CORROBORADO** — strongly supported by repeated observations and/or family-source correspondence, but not uniquely proven as source code.
- **NÃO DETERMINADO** — insufficient evidence.
- **REFUTADO** — tested and contradicted by observed behavior.

No coding of a replacement engine should begin until the behavioral specification is considered sufficiently closed.

---

# ETAPA 01 — ANATOMIA DA ENTRADA

## Findings

1. Zeus initializes a bilateral structure with one BUY STOP and one SELL STOP, both 0.01 lot.
2. Initial pending distance is `FirstStep=160 points = 1.60`.
3. Pending orders are dynamic objects: CREATE → PENDING → MODIFY → EXECUTE or DELETE.
4. The mechanism commonly called trailing is not conventional SL trailing; it repositions the pending order's open price (OOP). Log entries show `sl: 0.00 tp: 0.00`.
5. Execution of a pending order does not terminate the mechanism; new pending orders are created.
6. Bilateral pending structure can persist while a directional basket is active.
7. Lot size is dynamic.
8. Basket closures can close only one direction.
9. A separate `OrderCloseBy` hedge/compensation mechanism exists.
10. A pending order's creation price can differ from its eventual execution price because OOP is dynamically modified.
11. Reset/reconstruction can rebuild the bilateral pending structure.

## Rules

- E01-01: bilateral initialization.
- E01-02: FirstStep determines initial pending distance.
- E01-03: pending OOP is dynamic.
- E01-04: execution does not terminate expansion logic.
- E01-05: bilateral structure persists during directional exposure.
- E01-06: lot is dynamic.
- E01-07: execution occurs at the last valid OOP reached by the pending order.
- E01-08: certain closures trigger reconstruction.

---

# ETAPA 02 — MATEMÁTICA DO TRAILING DAS PENDENTES

Analysis of all observed OOP modifications identified exactly two direct geometric regimes:

- `FirstStep = 1.60`
- `MinDistance = 3.40`

No observed OOP modification was directly explained by 0.80 or 0.90.

## Exact formulas

BUY:

`OOP = Ask + 1.60`  (FirstStep regime)

`OOP = Ask + 3.40`  (MinDistance regime)

SELL:

`OOP = Bid - 1.60`  (FirstStep regime)

`OOP = Bid - 3.40`  (MinDistance regime)

Cross-correlation against the tick CSV showed approximately 0.50 price-unit reference movement between consecutive same-ticket OOP modifications, strongly supporting `StepTrallOrders=50 points = 0.50` as the trigger threshold.

The actual OOP increments vary because each modification recalculates the OOP from current Bid/Ask plus/minus the fixed regime distance.

## Rules

- E02-01: OOP follows market dynamically.
- E02-02: BUY uses ASK.
- E02-03: SELL uses BID.
- E02-04: direct trailing distances are 1.60 or 3.40.
- E02-05: FirstStep formulas above.
- E02-06: MinDistance formulas above.
- E02-07: an order remains in its active geometry regime.
- E02-08: StepTrallOrders ≈ 0.50 trigger.
- E02-09: this is not SL trailing.
- E02-10: pending OOP follows market movement.

---

# ETAPA 03 — MATEMÁTICA DO LOTE

**227 order creations** were analyzed.

Inputs:

- `lot = 0.01`
- `K_Lot = 1.2`
- `PlusLot = 0.01`
- `DigitsLot = 2`
- `Maxlot = 0.62`

Exact directional lot formula:

`Lot(n) = NormalizeDouble(lot * K_Lot^n + n * PlusLot, DigitsLot)`

then capped at `Maxlot`.

`n` is the current number of same-direction positions.

Observed sequence:

`0.01, 0.02, 0.03, 0.05, 0.06, 0.07, 0.09, 0.11, 0.12, 0.14, 0.16, 0.18, 0.21, 0.24, 0.27, 0.30, 0.34, 0.39, 0.45, 0.51, 0.58, 0.62`

BUY and SELL progressions are independent.

After the directional basket is zeroed, the next directional order returns to 0.01.

**Status: COMPROVADO.**

---

# ETAPA 04 — FORMAÇÃO DA CESTA / NOVA CAMADA

The basket layer mechanism is not simply `market ± MinDistance`.

Two geometric dimensions were identified:

### Base distance

- first directional order: `FirstStep = 1.60`
- subsequent normal orders: `MinDistance = 3.40`

### Layer admissibility / spacing

`Step = 80 points = 0.80` clearly participates in layer spacing.

Same-side creation sequences repeatedly show approximately 0.80–0.90 price-unit spacing.

`TwoStep=90` and `TwoMinDistance=80` were not uniquely proven in the observed Zeus test as direct active formulas.

The public same-family implementation corroborates an extrema-based candidate correction using Step/TwoStep and primary/secondary geometry, but this remains corroboration only.

**COMPROVADO:** MinDistance=3.40; Step participates in layer spacing.  
**HIPÓTESE FORTE:** extrema-based layer admissibility; secondary geometry.  
**NÃO DETERMINADO:** exact activation and formula of TwoStep/TwoMinDistance.

---

# ETAPA 05 — MATEMÁTICA DO FECHAMENTO DA CESTA

Normal directional basket P/L:

BUY:

`Profit = (Close - Open) * Lot * 100`

SELL:

`Profit = (Open - Close) * Lot * 100`

The spread is naturally incorporated when using the actual execution side:

BUY: `(Bid_close - Ask_open) * Lot * 100`  
SELL: `(Bid_open - Ask_close) * Lot * 100`

Aggregate directional P/L:

`BasketProfit_D = sum(Profit_i)`

Target:

`Target_D = N_D * StopProfit`

with `StopProfit=20`.

Examples observed:

- 2 SELL positions: 40.56 ≈ 2 × 20.
- 2 BUY positions: 40.10 ≈ 2 × 20.
- 4 SELL positions: 80.34 ≈ 4 × 20.
- 5 SELL positions: 100.25 ≈ 5 × 20.

Actual values can exceed the theoretical target because market price continues moving between eligibility and execution.

`CloseAll=4` is not a position-count threshold.

**Status: COMPROVADO.**

---

# ETAPA 06 — FECHAMENTO E RECONSTRUÇÃO PÓS-CESTA

Normal directional basket closure closes only that direction.

After a directional basket reaches its target, Zeus may create a new pending order in that direction and continue operation.

Global reset follows a different sequence:

1. identify opposing positions;
2. execute `OrderCloseBy` pairs;
3. when no valid pair remains, `OrderCloseBy error 4051` occurs;
4. residual positions are closed individually;
5. old pending orders are deleted;
6. a new BUY STOP 0.01 and SELL STOP 0.01 are opened;
7. pending trailing resumes.

**Status: COMPROVADO.**

---

# ETAPA 07 — ORDERCLOSEBY E CLOSEALL

A critical discovery is that unequal-lot `OrderCloseBy` operations generate a residual exposure represented by a new ticket.

For two opposite positions:

`A lot × B lot`

→ compensate `min(A,B)`  
→ larger side remains as residual  
→ residual appears as a new ticket  
→ residual participates in the next pairing.

Examples:

- BUY 0.05 vs SELL 0.09 → residual SELL 0.04 → new ticket.
- residual SELL 0.04 vs BUY 0.03 → residual SELL 0.01 → new ticket.
- residual SELL 0.01 vs BUY 0.02 → residual BUY 0.01 → new ticket.

General rule:

`equal lots → both disappear`

`A>B → B disappears, A residual becomes new ticket`

`B>A → A disappears, B residual becomes new ticket`

**Status: COMPROVADO.**

---

# ETAPA 08 — SELEÇÃO DOS PARES

Across 56 observed `order #X was closed by order #Y` lines grouped into 10 global events, the first active BUY and SELL selected were consistently the highest-ticket active position on each side.

When a residual was created, it became the newest active ticket and was selected on the next pairing against the highest remaining opposite-side ticket.

Behavioral rule:

`Partner(side) = max(ticket among active positions of opposite direction)`

This is strongly consistent with the family implementation's scan/selection behavior.

**Status: COMPROVADO behaviorally; exact source-loop implementation remains corroborative.**

---

# ETAPA 09 — GATILHO DO CLOSEALL

The main observed global path is:

`Profit_BUY + Profit_SELL >= CloseAll`

with `CloseAll=4`.

First nine global events strongly support this threshold, including totals around +4.31, +4.77, +4.86 and +5.17.

The 11:55 event is an exception/anomaly from the perspective of this simple rule: it is a protective global neutralization after extreme directional stress and therefore must not be forced into the normal +4 interpretation.

The family implementation corroborates two global branches:

1. normal global CloseAll by total floating P/L;
2. a separate protective branch involving `MaxLossCloseAll`.

`MaxLossCloseAll=100` is **not** proven as a simple `loss <= -100` trigger for all global events.

**Status:** main +4 path strongly corroborated; universal trigger remains unresolved.

---

# ETAPA 10 — MATEMÁTICA DO P/L

The observed Zeus P/L is standard XAUUSD price × lot economics.

BUY:

`Profit = (Bid_close - Ask_open) * Lot * 100`

SELL:

`Profit = (Bid_open - Ask_close) * Lot * 100`

Family code explicitly uses `OrderProfit()+OrderSwap()+OrderCommission()`. Exact Zeus implementation is not visible, but behavior is equivalent for the observed test.

**Status: COMPROVADO behaviorally.**

---

# ETAPA 11 — FECHAMENTO SELETIVO

Selective events consistently close exactly three positions from one direction.

The selected set is:

1. the position with the maximum positive P/L;
2. the position with the most negative P/L;
3. the position with the second most negative P/L.

Observed trio P/L totals are always slightly positive or approximately zero.

Examples:

- 03:17:40 SELL: +86.56 −47.97 −37.71 = +0.88.
- 03:19:38 SELL: +67.20 −33.54 −33.39 = +0.27.
- 11:45:37 BUY: +39.54 −21.21 −18.25 = +0.08.
- 16:39:02 BUY: +218.08 −108.18 −107.20 = +2.70.
- 11:54:40 SELL: +678.90 −341.04 −337.20 = +0.66.
- 11:55:36 SELL: +641.08 −320.96 −319.99 = +0.13.

**Status: COMPROVADO.**

---

# ETAPA 12 — GATILHO DO FECHAMENTO SELETIVO

The exposure imbalance rule emerged as a strong family-correlated candidate:

`Lots_D > Lots_Opp + 3 * WinnerLot_D`

with more than three positions in the dominant direction.

However, exposure imbalance alone was shown not to be sufficient: at 11:08:52 the exposure condition was true but no compression occurred.

Therefore a second economic condition exists.

**Status:** exposure rule strongly corroborated; not sufficient alone.

---

# ETAPA 13 — MÁQUINA DE SAÍDA

Three distinct economic mechanisms were separated:

### A. Basket realization

`Profit_D >= N_D * StopProfit`

### B. Selective compression

Close the maximum-P/L winner plus the two worst losses in the same direction, with approximately zero/positive realized P/L.

### C. Global neutralization

`OrderCloseBy → residuals → cleanup → reset`.

The exact priority when multiple routines are simultaneously eligible was intentionally left unresolved for Stage 30.

---

# ETAPA 14 — ALGORITMO DE SELEÇÃO E PROTEÇÃO

Behaviorally:

`Winner_D = argmax(P/L_i)`

`Loss1, Loss2 = two minimum P/L positions`

`CloseSet = {Winner, Loss1, Loss2}`

This is not a global optimization over all possible trios.

The public family source corroborates separate routines for selecting maximum positive and minimum negative P/L positions.

**Status: COMPROVADO behaviorally.**

---

# ETAPA 15 — ESPECIFICAÇÃO COMPORTAMENTAL CONSOLIDADA

High-level states:

- S0 initialization.
- S1 dynamic pending.
- S2 execution/expansion.
- S3 layer formation.
- S4 basket close.
- S5 selective compression.
- S6 protection trigger.
- S7 CloseAll.
- S8 OrderCloseBy.
- S9 4051.
- S10 cleanup.
- S11 reset/reconstruction.

Unresolved:

- exact TwoMinDistance;
- exact TwoStep;
- exact MaxLossCloseAll role;
- exact priority among routines;
- exact internal protection boolean.

---

# ETAPA 16 — MÁQUINA DE ESTADOS

Conceptual flow:

`RESET`

→ `BILATERAL BUY+SELL PENDENTES`

→ `EXPANSÃO`

→ either:

- Basket Target → directional closure;
- Protection → compression;
- CloseAll → OrderCloseBy.

Then:

`OrderCloseBy → 4051 → Cleanup → Reset`.

This is a behavioral state machine, not an implementation specification.

---

# ETAPA 17 — FALSIFICAÇÃO DAS REGRAS

Validated without observed counterexample:

- Basket `Profit_D >= N*20`: PASS.
- Lot formula: PASS.
- OOP trailing geometry: PASS.
- Highest-ticket OrderCloseBy selection: PASS.
- Residual → new ticket: PASS.
- 4051 ending valid pairing: PASS.
- Bilateral 0.01/0.01 rebuild: PASS.
- Winner + two worst losses: PASS.
- Compression near-zero positive P/L: PASS.

Refuted:

- `3×WinnerLot` as a standalone sufficient condition.
- `MaxLossCloseAll=100` as a universal direct trigger.
- CloseAll +4 as universal global trigger.
- Any claim that Zeus globally optimizes the best possible trio.

The apparent 11:45 counterexample to `3×WinnerLot` was itself later identified as a state-reconstruction error and therefore removed from the falsification set.

---

# ETAPA 18 — RECONSTRUÇÃO TEMPORAL DOS CICLOS

Selective compression occurs during expansion and does not necessarily cause reset.

Examples:

- 03:17:40 and 03:19:38 compressions are followed by continued order creation.
- 11:00:00 and 11:45:37 compressions occur while expansion continues.
- 11:54:40 and 11:55:36 compressions are separated by only 56 seconds and are followed by global neutralization two seconds later.

This supports at least two protective levels:

`Level 1 = compression`

`Level 2 = global neutralization`.

---

# ETAPA 19 — EXPOSIÇÃO E PROTEÇÃO

Compression is not triggered by absolute directional P/L.

It is associated with strong directional lot imbalance.

The 11:55 global liquidation after the two compressions is protective and can leave substantial negative realized P/L.

The exact escalation condition remained unresolved at this stage.

---

# ETAPA 20 — CORREÇÃO DO FALSO CONTRAEXEMPLO

An apparent violation of `Lots_D > Lots_Opp + 3*WinnerLot` at 11:45 was caused by carrying tickets from before the 08:23 reset into the later state.

After reconstructing the correct state:

BUY = 0.25  
SELL = 0.06  
WinnerLot = 0.06

Therefore:

`0.25 > 0.06 + 3*0.06`

`0.25 > 0.24` → TRUE.

This correction is important: it restored the 3×WinnerLot rule as a strong candidate rather than a falsified one.

---

# ETAPA 21 — LEDGER DE EXPOSIÇÃO

A fully generic parser became unreliable after global `OrderCloseBy` events because residual tickets are not necessarily represented by explicit Tester-open lines and ticket numbering can interact with pending orders.

Therefore:

- explicit Tester executions are authoritative for opening positions;
- state reconstruction between reset boundaries is reliable;
- generic synthetic residual inference must not be treated as authoritative.

Correct post-08:23 exposure examples were reconstructed manually/statefully.

---

# ETAPA 22 — IMPLEMENTAÇÃO PÚBLICA DA FAMÍLIA

The public family implementation corroborates the following structural concepts:

- `CloseBuySell`.
- `HomeopathyCloseAll`.
- `Money`.
- `FirstStep`.
- `MinDistance`.
- `TwoMinDistance`.
- `StepTrallOrders`.
- `Step`.
- `TwoStep`.
- `MaxLoss`.
- `MaxLossCloseAll`.
- `CloseAll`.
- `Profit`.
- `StopProfit`.
- `StopLoss`.

It also corroborates:

- accumulation of BUY/SELL counts, lots and P/L;
- lot-imbalance flags;
- a `do32` distribution metric;
- selection of maximum profit and minimum losses;
- the `3×WinnerLot` exposure condition;
- global CloseAll using aggregate P/L;
- a separate global protective branch;
- `OrderCloseBy` pairing;
- global cleanup/reset;
- `Money` switching primary/secondary spacing.

**Critical forensic rule:** this source is corroborative only. Decompiled variable names and control flow must not be assumed identical to Zeus V1.2 without behavioral confirmation.

---

# ETAPA 23 — FALSIFICAÇÃO DO GATILHO DE PROTEÇÃO

The corrected state reconstruction removed the previous counterexample.

Current status:

- 3×WinnerLot exposure condition: strongly corroborated.
- exact boolean trigger: still requires economic-distribution confirmation.

---

# ETAPA 24 — MÉTRICA DE DISTRIBUIÇÃO DE P/L

Initial candidate:

`D_N = sum(selected positive P/L) - sum(selected loss magnitudes)`.

This was not yet tied exactly to Zeus internals.

The observed selection remained unequivocal:

`Winner + two worst losses`.

The key forensic separation became:

1. Why compress? = eligibility/trigger.
2. What to compress? = deterministic ranking selection.

---

# ETAPA 25 / 25.12 — CONTROLES NEGATIVOS

Second-by-second temporal analysis established:

- exposure condition can be true without compression;
- immediately before compression the selected trio can still be negative;
- at the compression tick the trio crosses into positive/near-zero territory.

Key transitions:

- 03:17:39 → trio −0.52; 03:17:40 → +0.88.
- 03:19:37 → −0.27; 03:19:38 → +0.27.
- 11:45:36 → −1.18; 11:45:37 → +0.08.
- 14:02:38 → −2.53; 14:02:39 → +0.35.
- 16:39:01 → −13.50; 16:39:02 → +2.70.
- 18:16:00 → −1.71; 18:16:01 → +0.11.
- 20:07:04 → −0.19; 20:07:05 → +0.11.
- 05:39:35 → −1.70; 05:39:36 → +0.01.
- 11:54:39 → −3.26; 11:54:40 → +0.66.
- 11:55:35 → −6.99; 11:55:36 → +0.13.

This is the strongest behavioral evidence for an economic eligibility gate.

---

# ETAPA 26 — MATRIZ DE VALIDAÇÃO

For all 11 observed compression events:

`Lots_D > Lots_Opp + 3*WinnerLot` = TRUE.

`N_D > 3` = TRUE.

The actual selected trio is positive/near-zero at closure.

Negative controls where exposure was true but compression was absent showed the selected trio remained negative.

Therefore the best behavioral model became:

`ExposureImbalance AND N>3 AND TrioFinancingCapacity >= 0 → Compression`.

The exact internal representation was still unknown at the end of this stage.

---

# ETAPA 27 — OTIMIZAÇÃO DA COMPRESSÃO E OBJETIVO ECONÔMICO

All 3-position combinations in the same direction were tested at actual compression prices.

The test refuted three possible objectives:

1. maximize lots removed;
2. maximize realized profit;
3. globally optimize all possible trios.

The actual Zeus choice is a deterministic ranking:

`Winner = maximum P/L`

`Loss1/Loss2 = two minimum P/L`

The economic effect is inventory compression with near-zero positive realized P/L.

Observed lot reductions ranged from roughly 13% to 75% of the dominant directional exposure in the studied events.

Large-basket events such as 11:54 prove that the EA is not performing global combinatorial optimization: it follows the ranking rule even when another trio could remove more lots or produce different P/L.

Conceptual interpretation:

> Retire risk from the table when a sufficiently large winner can pay the two worst losers.

Status:

- exposure reduction: COMPROVADO;
- near-zero realized P/L: COMPROVADO;
- deterministic winner/two-worst selection: COMPROVADO;
- maximize lots: REFUTADO;
- maximize profit: REFUTADO;
- global combinatorial optimization: REFUTADO.

---

# ETAPA 28 — FUNÇÃO DE ELEGIBILIDADE DA COMPRESSÃO

The behavioral function reconstructed was:

`Eligible_D = ExposureGate_D AND CountGate_D AND EconomicGate_D`

where:

`ExposureGate_D = Lots_D > Lots_Opp + 3*WinnerLot_D`

`CountGate_D = Count_D > 3`

`EconomicGate_D = Winner_D + WorstLoss1_D + WorstLoss2_D >= 0`

The important conceptual result:

**Exposure pressure** and **economic opportunity** are separate conditions.

The 11:08:52 control case demonstrates that exposure pressure alone does not trigger compression.

The economic gate was still expressed behaviorally at the end of Stage 28.

---

# ETAPA 29 — RECONSTRUÇÃO DE `do32`

This stage connects the observed economic gate to the family implementation's `do32` / `lizong_10` structure.

## 29.1 Behavioral reconstruction

`lizong_10` separates directional positions into:

- non-negative P/L;
- negative P/L converted to positive loss magnitude.

It sorts the values and returns the requested number of entries.

The family CloseBuySell logic uses one top positive and two top negative values.

Therefore the reconstructed metric is:

`do32_D = Winner_D - |WorstLoss1_D| - |WorstLoss2_D|`

Equivalently:

`do32_D = Winner_D + WorstLoss1_D + WorstLoss2_D`

because `WorstLoss1` and `WorstLoss2` are negative P/L values.

## 29.2 Eligibility

The economic gate therefore becomes:

`do32_D > 0`

and the complete behavioral eligibility function is:

### BUY

`Eligible_BUY = (BuyLots > SellLots + 3*WinnerLot_BUY) AND (BuyCount > 3) AND (do32_BUY > 0)`

### SELL

`Eligible_SELL = (SellLots > BuyLots + 3*WinnerLot_SELL) AND (SellCount > 3) AND (do32_SELL > 0)`

## 29.3 Empirical demonstrations

11:45:37 BUY:

`39.54 - 21.21 - 18.25 = +0.08`

11:54:40 SELL:

`678.90 - 341.04 - 337.20 = +0.66`

11:55:36 SELL:

`641.08 - 320.96 - 319.99 = +0.13`

In each case the three corresponding tickets were closed.

## 29.4 Role of `do23`

The family implementation also maintains a maximum of the distribution metric over the current state:

`do23 = max(do23, do32)`

The observed behavior, however, shows that the current `do32` crossing positive is the economically decisive event for the compression. The exact use of historical `do23` inside Zeus V1.2 remains source-level corroboration, not direct proof.

## 29.5 What `do32` is NOT

- not total directional P/L;
- not an average;
- not a percentage;
- not a global optimization score over all trios;
- not simply `MaxLossCloseAll`.

## 29.6 Economic interpretation

`do32 > 0` means:

`Winner > |Loss1| + |Loss2|`

The largest winner can therefore finance the two worst losses.

This explains why realized compression P/L repeatedly lands around zero while reducing directional inventory.

## 29.7 Forensic status

**COMPROVADO behaviorally:** the winner and two worst losses produce the observed economic gate.

**HIPÓTESE FORTE / CORROBORADO:** the internal family metric `do32` is exactly this calculation through `lizong_10`.

**NÃO PROVADO:** that Zeus V1.2 contains the exact same source variable names/functions or byte-for-byte implementation.

---

# CURRENT MASTER BEHAVIORAL MODEL — END OF STAGE 29

## Entry / expansion

1. Start with BUY STOP 0.01 and SELL STOP 0.01.
2. Initial geometry uses FirstStep 1.60.
3. Pending OOP trails dynamically using ASK for BUY and BID for SELL.
4. Direct pending trailing uses 1.60 or 3.40 geometry.
5. StepTrallOrders is approximately 0.50.
6. Executed positions cause continued expansion and new pending orders.
7. Directional lots follow the proven exponential-plus-linear formula and cap at 0.62.
8. Layer spacing uses Step=0.80; secondary geometry remains unresolved.

## Directional basket realization

`BasketProfit_D >= Count_D * 20`

→ close the directional basket.

## Selective compression

For direction D:

`Winner = argmax(P/L)`

`Loss1, Loss2 = two minimum P/L positions`

Eligible if:

`Lots_D > Lots_Opp + 3*WinnerLot_D`

AND

`Count_D > 3`

AND

`do32_D > 0`

where:

`do32_D = Winner_D - |Loss1_D| - |Loss2_D|`

Then close the three selected positions.

## Global neutralization

A normal path is strongly associated with:

`Profit_BUY + Profit_SELL >= CloseAll`

with `CloseAll=4`.

A separate protective global path exists but its exact Zeus V1.2 boolean remains unresolved.

Then:

`OrderCloseBy`

→ unequal-lot residuals become new tickets

→ continue pairing highest-ticket positions

→ 4051 when no valid pair remains

→ individual cleanup

→ delete pending orders

→ rebuild bilateral 0.01/0.01

→ resume.

---

# OPEN QUESTIONS ENTERING STAGE 30

1. **Priority of routines:** What exact order does Zeus evaluate when Basket Target, Compression and Global Protection/CloseAll are simultaneously eligible on the same tick?
2. **Same-tick interaction:** Can a basket close occur before compression, or vice versa?
3. **Global protective branch:** What exact observed state maps to `MaxLossCloseAll`?
4. **Secondary geometry:** Under exactly what condition do `TwoMinDistance` and `TwoStep` become active?
5. **Money / regime switching:** Can the state be inferred from Zeus behavior rather than family source?
6. **Historical metric:** Is `do23` behaviorally relevant to Zeus V1.2 or merely an implementation detail of the related family version?
7. **Exact execution ordering:** When several conditions are true in one tick, which function executes first and how does the state mutate before the next function sees it?

These questions are deliberately preserved. They must not be silently resolved by assumptions.

---

# FORENSIC CHECKPOINT STATUS

**Frozen knowledge state:** END OF ETAPA 29  
**Next authorized investigation:** ETAPA 30 — Reconstrução da prioridade de execução  
**Implementation status:** NO NEW ENGINE / NO CODE SPECIFICATION AUTHORIZED YET  
**Evidence principle:** Zeus log + Zeus tick CSV first; family source only as corroboration.

---

## Parameter Baseline Observed in Zeus V1.2

`Magic=1001`  
`StopProfit=20`  
`StopLoss=0`  
`lot=0.01`  
`K_Lot=1.2`  
`DigitsLot=2`  
`CloseAll=4`  
`PlusLot=0.01`  
`Maxlot=0.62`  
`MaxSpread=100`  
`NextTime=0`  
`FirstStep=160`  
`MinDistance=340`  
`TwoMinDistance=80`  
`StepTrallOrders=50`  
`Step=80`  
`TwoStep=90`  
`MaxLoss=100000`  
`MaxLossCloseAll=100`  
`Totals=2000`  
`Leverage=100`

---

**END OF FORENSIC CHECKPOINT — ETAPA 29**
