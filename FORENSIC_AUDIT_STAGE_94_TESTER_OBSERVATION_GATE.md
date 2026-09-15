# FORENSIC AUDIT — STAGE 94
## Strategy Tester Observation Gate

Status: PROVISIONED — execution disabled

### Objective
Prepare the ZGOLD branch for the first real MT4 Strategy Tester observation run without introducing trading execution.

### Observation boundary
This stage may observe:
- tick time;
- Bid/Ask;
- lifecycle result already detected by the existing reconciler;
- decision output already produced by existing observers;
- operational state already produced by the current controller.

This stage must not call:
- OrderSend;
- OrderModify;
- OrderClose;
- OrderCloseBy;
- pending deletion;
- reset/reconstruction execution.

### Probe
`ZGOLD/Debug/TesterObservationProbe.mqh`

The probe is deliberately passive. It records only tester/runtime observations supplied by the controller. It does not synthesize orders or infer missing Zeus behavior.

### Test objective
The first external MT4 tester run should establish that:
1. the EA loads successfully;
2. OnInit/OnTick/OnDeinit execute normally;
3. market observations advance across the tester interval;
4. lifecycle/decision/state observations can be surfaced;
5. the trace can subsequently be normalized into the Stage 90/91 comparison schema.

### Important distinction
A successful tester load is **not** evidence that ZGOLD reproduces Zeus. It only establishes executable observation infrastructure.

The next comparison stage must use the actual ZGOLD tester output against `ZEUS_STAGE92_REFERENCE_TRACE.csv` and must report the first causal divergence only where the two streams have sufficient comparable evidence.

### Current repository condition
The main `ZGOLD.mq4` remains explicitly marked `NO TRADING LOGIC`. Therefore this stage cannot generate an execution-equivalent Zeus order stream yet.

### Next stage
Stage 95: obtain and normalize the first actual ZGOLD Strategy Tester trace, then perform the first empirical Zeus-vs-ZGOLD alignment pass.
