# FORENSIC AUDIT — STAGE 92
## Structured Backtest Observation Pass

Status: COMPLETED — reference observation only; ZGOLD execution remains disabled.

### Objective
Run the first structured observation pass against the available Zeus Gold Hedge V1.2 Strategy Tester evidence and establish a machine-readable reference baseline for the later ZGOLD replay comparison.

### Source evidence
- `Comportamento EA.log`
- `Comportamento EA.csv`
- Symbol: XAUUSD
- Digits: 2
- Point: 0.01
- Tester tick stream: 413,774 tick events
- Test interval observed: 2026.06.01 01:00:00 through 2026.06.02 12:04:01

### Reference event extraction
The pass produced the following normalized event counts from the Zeus log:

| Event | Count |
|---|---:|
| CREATE / pending open requests | 227 |
| MODIFY / pending OOP modifications | 500 |
| EXECUTE / pending-to-market executions | 221 |
| CLOSEBY pair events | 56 |
| CLOSEBY bursts | 10 |

CREATE direction split:
- SELL STOP: 141
- BUY STOP: 86

EXECUTE direction split:
- SELL: 141
- BUY: 80

### Important forensic observations confirmed by this pass
1. Pending orders form a first-class lifecycle: CREATE -> MODIFY -> EXECUTE/DELETE.
2. The 500 MODIFY records are explicit OOP repositioning events with SL=0 and TP=0 in the source log.
3. CloseBy is emitted as multiple paired closure events inside discrete transaction bursts; it must therefore be modeled as a burst/state transition rather than a single scalar event.
4. The reference stream contains more CREATE requests than EXECUTE events, confirming that pending lifecycle and cleanup must be represented independently.
5. The extracted trace preserves the exact event timestamp and ticket identity available in the source log.

### Machine-readable reference artifact
A normalized reference trace was generated outside the repository for this pass:
`ZEUS_STAGE92_REFERENCE_TRACE.csv`

Schema:
`Timestamp;EventType;Ticket;Direction;Lots;Price;ByTicket`

Rows: 1,004

This file is the Stage 92 reference baseline to feed the replay comparator in the next stage.

### Comparator status
No ZGOLD-vs-Zeus divergence claim is made in Stage 92 because the current ZGOLD branch is still observation-only and no MT4 Strategy Tester execution trace from ZGOLD has yet been supplied. Consequently:

- Event Match: UNRESOLVED
- Decision Match: UNRESOLVED
- Price Match: UNRESOLVED
- Lot Match: UNRESOLVED
- Lifecycle Match: UNRESOLVED
- First causal divergence: UNRESOLVED

### Safety boundary
No `OrderSend`, `OrderModify`, `OrderClose`, `OrderCloseBy`, pending deletion, or reset execution was introduced by this pass.

### Next stage
Stage 93 should connect the normalized Zeus reference baseline to an actual ZGOLD Strategy Tester observation run, then perform timestamp/event alignment and identify the first causal divergence D0-D5.
