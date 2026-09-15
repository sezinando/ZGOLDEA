#ifndef __ZGOLD_EA_CONTROLLER_MQH__
#define __ZGOLD_EA_CONTROLLER_MQH__
#include "../State/MarketState.mqh"
#include "../State/StateReconciler.mqh"
#include "../State/OperationalState.mqh"
#include "../Debug/DebugPanel.mqh"
#include "../Engine/PendingTrailingObserver.mqh"
#include "../Engine/PendingTrailingDecisionObserver.mqh"
#include "../Engine/PendingTrailCandidateObserver.mqh"
class EAController
{
private:
 MarketState m_market; StateReconciler m_reconciler; DebugPanel m_panel; PendingTrailingObserver m_trailing; PendingTrailingDecisionObserver m_trailing_decision; PendingTrailCandidateObserver m_candidate; OperationalState m_operational_state; bool m_initialized; int m_magic;
 void UpdateTrailingObserver(PendingState &p){m_trailing.EvaluateAll(p,m_market.Bid(),m_market.Ask());int tickets[ZGOLD_TRAIL_MAX];int types[ZGOLD_TRAIL_MAX];double deltas[ZGOLD_TRAIL_MAX];string classes[ZGOLD_TRAIL_MAX];bool valids[ZGOLD_TRAIL_MAX];for(int i=0;i<ZGOLD_TRAIL_MAX;i++){tickets[i]=m_trailing.Ticket(i);types[i]=m_trailing.Type(i);deltas[i]=m_trailing.Delta(i);classes[i]=m_trailing.DistanceClass(i);valids[i]=m_trailing.Valid(i);}m_panel.SetTrailingInventory(m_trailing.Count(),tickets,types,deltas,classes,valids);}
 void UpdateDecisionObserver(PendingState &p){m_trailing_decision.Evaluate(p,m_trailing,m_market.Bid(),m_market.Ask());m_panel.SetDecisionAction(m_trailing_decision.DecisionText(m_trailing),m_trailing_decision.ActionText(m_trailing),m_trailing_decision.ReasonText(m_trailing),m_trailing_decision.DecisionTicket(m_trailing));}
 void UpdateCandidateObserver(PendingState &p){m_candidate.Evaluate(p,m_trailing);int tickets[ZGOLD_CANDIDATE_MAX];double prices[ZGOLD_CANDIDATE_MAX];bool valids[ZGOLD_CANDIDATE_MAX];string reasons[ZGOLD_CANDIDATE_MAX];for(int i=0;i<ZGOLD_CANDIDATE_MAX;i++){tickets[i]=m_candidate.Ticket(i);prices[i]=m_candidate.Candidate(i);valids[i]=m_candidate.Valid(i);reasons[i]=m_candidate.Reason(i);}m_panel.SetCandidateInventory(m_candidate.Count(),tickets,prices,valids,reasons);}
 void UpdatePanel(){ExposureState e;PendingState p;m_reconciler.CopyExposureTo(e);m_reconciler.CopyPendingTo(p);m_operational_state.Evaluate(e,p);m_panel.SetMarket(m_market.Bid(),m_market.Ask(),m_market.SpreadPoints(),m_market.ServerTime());m_panel.SetExposure(e.BuyCount(),e.BuyLots(),e.BuyProfit(),e.SellCount(),e.SellLots(),e.SellProfit(),e.TotalProfit());m_panel.SetPending(p);m_panel.SetOperationalState(m_operational_state.State(),m_operational_state.Reason());m_panel.SetLifecycle(m_reconciler.LifecycleEvent(),m_reconciler.LifecycleTicket(),m_reconciler.LifecyclePreviousType(),m_reconciler.LifecycleType(),m_reconciler.LifecyclePreviousLots(),m_reconciler.LifecycleLots(),m_reconciler.LifecyclePreviousPrice(),m_reconciler.LifecyclePrice(),m_reconciler.LifecycleText());UpdateTrailingObserver(p);UpdateDecisionObserver(p);UpdateCandidateObserver(p);}
public:
 EAController(){m_initialized=false;m_magic=1001;}
 void SetMagic(int magic){m_magic=magic;m_reconciler.SetMagic(magic);}
 int Initialize(){m_panel.Initialize();m_panel.SetModuleStatus("CORE",true);m_panel.SetModuleStatus("MARKET STATE",true);m_panel.SetModuleStatus("STATE RECONCILER",true);m_panel.SetModuleStatus("PENDING TRAILING",true);m_panel.SetModuleStatus("OPERATIONAL STATE",true);m_panel.SetModuleStatus("DECISION OBSERVER",true);m_panel.SetModuleStatus("CANDIDATE OBSERVER",true);m_panel.SetLastEvent("EA initialized");m_reconciler.SetMagic(m_magic);m_market.Update();m_reconciler.Reconcile();UpdatePanel();m_panel.SetRuntimeState("RUNNING");m_panel.SetLastEvent(m_reconciler.LifecycleText());m_panel.Render();Print("[ZGOLD] Fragment 13 initialized - candidate price observer");m_initialized=true;return INIT_SUCCEEDED;}
 void ProcessTick(){if(!m_initialized)return;m_market.Update();m_reconciler.Reconcile();m_panel.IncrementTick();UpdatePanel();m_panel.SetLastEvent(m_reconciler.LifecycleText());m_panel.Render();}
 void Shutdown(const int reason){m_panel.SetRuntimeState("STOPPED");m_panel.SetLastEvent("EA deinitialized");m_panel.Render();m_panel.Destroy();Print("[ZGOLD] Debug Panel removed. Reason=",reason);m_initialized=false;}
};
#endif
