# FORENSIC AUDIT CHECKPOINT — Zeus Gold Hedge V1.2

## ETAPA 33 — PendingTrailingEngine

**Repository:** `sezinando/ZGOLDEA`
**Scope:** forensic reverse engineering only
**Source of truth:** observed Zeus Gold Hedge V1.2 behavior in `Comportamento EA.log` and `Comportamento EA.csv`.
**Important:** public implementations from the same EA family are corroborative only; they are not treated as proof of Zeus V1.2 internals.

---

## 1. Objective

Reconstruct the `PendingTrailingEngine` as an independent behavioral machine, separating it from the `NextLayerEngine`.

The engine answers:

> While a pending order exists, when and to what price does Zeus reposition its entry price (`OOP`)?

---

## 2. Core finding

Zeus does **not** perform conventional stop-loss trailing on pending orders.

The observed mechanism is dynamic repositioning of the pending order's own entry price (`OOP`). Orders are repeatedly modified with:

- `sl = 0.00`
- `tp = 0.00`

Therefore:

`PendingTrailingEngine = Dynamic Entry Repositioning`

not conventional SL trailing.

---

## 3. Directional reference

For BUY STOP:

`OOP_BUY = Ask + D`

For SELL STOP:

`OOP_SELL = Bid - D`

Observed behavior strongly supports:

- BUY uses **ASK** as market reference.
- SELL uses **BID** as market reference.

This is classified as **COMPROVADO**.

---

## 4. Trailing distance

The observed trailing OOPs are explained by two proven base-distance regimes:

- `FirstStep = 160 points = 1.60`
- `MinDistance = 340 points = 3.40`

Thus:

`D ∈ {1.60, 3.40}`

for the trailing regimes proven by the observed data.

`TwoMinDistance` and `TwoStep` remain unresolved as to whether they participate in Zeus V1.2 trailing specifically.

---

## 5. StepTrallOrders

Input:

`StepTrallOrders = 50 points`

With XAUUSD `Point = 0.01`:

`50 points = 0.50`

Cross-correlation of OOP modifications with the tick data showed that consecutive same-ticket trailing transitions require approximately 0.50 or more movement of the directional market reference. Actual OOP increments are often 0.51, 0.52, 0.53, etc., because Zeus recalculates the OOP from the current market rather than adding a fixed 0.50 to the previous OOP.

Status: **COMPROVADO / very strong behavioral evidence**.

---

## 6. Important distinction: StepTrallOrders vs Step

Two different mechanisms must not be conflated:

### `StepTrallOrders = 0.50`

Controls the approximate minimum market-reference displacement required before another pending OOP modification is made.

### `Step = 0.80`

Belongs primarily to next-layer geometry / layer formation.

They are different mechanisms.

---

## 7. OOP is recalculated from market

The engine does not simply perform:

`OOP_new = OOP_old ± 0.50`

Instead it recalculates:

BUY:
`OOP_new = Ask + D`

SELL:
`OOP_new = Bid - D`

The 0.50 threshold controls when the recalculation is worth applying.

This explains why observed OOP increments vary slightly above 0.50.

---

## 8. Pending lifecycle

Observed examples demonstrate:

`OrderSend pending`
→ `multiple OrderModify(OOP)`
→ `execution at latest valid OOP`

Example: BUY ticket #217 was repeatedly modified from the pending state and finally executed at its latest OOP, 4477.83. The log records the modification sequence and final execution. See `Comportamento EA.log` around 05:40–05:41 on 2026-06-02.

Example file evidence:
`fileciteturn34file0L11-L22`

Another SELL pending (#250) was repeatedly modified before execution at the latest OOP, demonstrating the same lifecycle.

Example:
`fileciteturn34file1L35-L46`

---

## 9. Trailing persists until execution

A pending can remain alive for a significant interval while its OOP follows the market.

Example BUY STOP #172 was modified repeatedly over several minutes before finally executing at 4481.03.

Evidence:
`fileciteturn34file4L104-L116`

Therefore:

`OrderSend != FinalEntry`

The OrderSend price is only the initial state of the pending.

---

## 10. Execution terminates trailing for that ticket

Once:

`Pending → Position`

that ticket is no longer a pending order and the PendingTrailingEngine no longer operates on it.

The system can subsequently create another pending ticket through the NextLayerEngine.

This creates the cycle:

`Pending → Trailing → Execution → New Layer → New Pending`

---

## 11. Execution is not the only conceptual trigger for the next pending

The forensic model must not assume:

`Execution → automatically create pending`

as the literal causal rule.

Execution changes the state and may make the NextLayerEngine eligible, but the next pending is ultimately subject to candidate generation, geometry, admissibility, and the Order Creation Gate reconstructed in ETAPA 32.5.

---

## 12. Reference-memory hypothesis

The observed behavior strongly implies that the engine needs some form of previous trailing reference, because it must determine whether the market has moved approximately 0.50 since the last modification.

Behavioral representation:

`abs(CurrentReference - LastTrailingReference) >= StepTrallOrders`

However, the literal implementation variable/storage mechanism is **NOT DETERMINED**.

Do not claim a specific variable name or implementation structure without additional evidence.

---

## 13. Logger anomaly

The text following `OOP old -> new` is not always reliable as a literal previous OOP.

Example around 01:00:29–01:00:36 shows a BUY modification whose logged old OOP references a value associated with another pending event, while the `modify #ticket ... at NEW_PRICE` line identifies the new OOP reliably.

Evidence:
`fileciteturn34file2L58-L69`

Therefore the audit rule is:

**Use `modify #ticket ... at NEW_PRICE` as the authoritative observed new OOP. Treat the textual `OOP old -> new` old-value field as potentially corrupted/shared-temporary logger output.**

This anomaly must not be mistaken for a real pending-price jump.

---

## 14. Independent machine model

Behavioral reconstruction:

```text
PENDING EXISTS
      |
      v
NEW TICK
      |
      v
SELECT MARKET REFERENCE
      |
      +-- BUY  -> Ask
      |
      +-- SELL -> Bid
      |
      v
SELECT DISTANCE REGIME
      |
      +-- 1.60
      +-- 3.40
      |
      v
CALCULATE TARGET OOP
      |
      +-- BUY  -> Ask + D
      +-- SELL -> Bid - D
      |
      v
CHECK TRAILING DISPLACEMENT
      |
      +-- < 0.50 -> WAIT
      |
      +-- >= 0.50
              |
              v
        OrderModify(OOP)
              |
              v
        PENDING REMAINS
              |
              v
        NEXT TICK
              |
              ...
              |
              v
           EXECUTION
              |
              v
        TRAILING ENDS
```

---

## 15. Current formal behavioral specification

For each pending order:

```text
if BUY STOP:
    Reference = Ask
    TargetOOP = Reference + Distance

if SELL STOP:
    Reference = Bid
    TargetOOP = Reference - Distance

if market-reference displacement since the last
trailing modification is approximately >= StepTrallOrders:
    OrderModify(ticket, TargetOOP, SL=0, TP=0)
else:
    do nothing
```

Parameters proven in this test:

- `FirstStep = 1.60`
- `MinDistance = 3.40`
- `StepTrallOrders = 0.50`
- `SL = 0`
- `TP = 0`

---

## 16. Status matrix

| Mechanism | Status |
|---|---|
| OOP is modified, not SL | 🟢 COMPROVADO |
| BUY reference = ASK | 🟢 COMPROVADO |
| SELL reference = BID | 🟢 COMPROVADO |
| StepTrallOrders ≈ 0.50 | 🟢 COMPROVADO |
| OOP recalculated from market | 🟢 COMPROVADO |
| Pending is trailed while alive | 🟢 COMPROVADO |
| Trailing ends on execution | 🟢 COMPROVADO |
| FirstStep 1.60 is a valid regime | 🟢 COMPROVADO |
| MinDistance 3.40 is a valid regime | 🟢 COMPROVADO |
| Final execution uses latest valid OOP | 🟢 COMPROVADO |
| OOP old-value logger field always reliable | 🔴 REFUTADO |
| Last-reference memory exists conceptually | 🟡 HIPÓTESE FORTE |
| Exact internal trailing boolean | 🟡 NÃO DETERMINADO |
| TwoMinDistance in trailing | 🟡 NÃO DETERMINADO |
| TwoStep in trailing | 🟡 NÃO DETERMINADO |

---

## 17. Relationship with NextLayerEngine

The two engines are now conceptually separated:

```text
NEXT LAYER ENGINE
    |
    +-- DistanceSelector
    +-- CandidateBuilder
    +-- GeometryConstraint
    +-- LayerAdmissibility
    +-- OrderCreationGate
    |
    v
OrderSend
    |
    v
PENDING
    |
    v
PENDING TRAILING ENGINE
    |
    +-- Market Reference
    +-- Distance Regime
    +-- StepTrallOrders Gate
    +-- OrderModify
    |
    v
EXECUTION
    |
    v
NEXT LAYER ENGINE
```

This separation is considered a major architectural reconstruction result, but it is a **behavioral model**, not authorization to implement code yet.

---

## 18. Unresolved questions after ETAPA 33

1. Exact literal storage of the last trailing reference.
2. Exact order of PendingTrailingEngine vs NextLayerEngine execution within the same `OnTick`.
3. Exact regime selection between FirstStep and MinDistance for an already-created pending.
4. Whether `TwoMinDistance` / `TwoStep` ever participate in Zeus V1.2 pending trailing.
5. Whether additional temporal/state gates can suppress `OrderModify` beyond the 0.50 displacement rule.

---

## 19. Next investigation

### ETAPA 34 — PendingLifecycleManager

Objective:

Reconstruct the complete pending lifecycle rather than only its trailing subroutine:

`CREATE → PENDING → MODIFY → MODIFY → ... → EXECUTE`

and determine precisely:

- when a pending becomes eligible for trailing;
- when it is excluded from trailing;
- how structural changes affect a live pending;
- how execution transfers control back to layer formation;
- how deletion/reset interacts with pending state;
- whether more than one pending can coexist per direction under each state.

Only after this should the investigation move toward reconstructing the central `OnTick` scheduler.

---

## Audit discipline

All future stages must preserve these rules:

1. Observed Zeus behavior has priority.
2. Public same-family code is corroboration, not proof.
3. Label conclusions as COMPROVADO / HIPÓTESE / NÃO DETERMINADO / REFUTADO.
4. Do not silently import architecture from previous projects.
5. Do not write implementation code until the behavioral specification is sufficiently closed.
