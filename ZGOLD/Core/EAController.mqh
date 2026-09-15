#ifndef __ZGOLD_EA_CONTROLLER_MQH__
#define __ZGOLD_EA_CONTROLLER_MQH__
#include "../State/MarketState.mqh"
#include "../State/StateReconciler.mqh"
#include "../State/OperationalState.mqh"
#include "../Debug/DebugPanel.mqh"
#include "../Engine/PendingTrailingObserver.mqh"
#include "../Engine/PendingTrailingDecisionObserver.mqh"
#include "../Engine/GeometryObserver.mqh"
#include "../Engine/LayerEngineObserver.mqh"
#include "../Engine/ExitEngineObserver.mqh"
class EAController
{
private:
 MarketState m_market; StateReconciler m_reconciler; DebugPanel m_panel; PendingTrailingObserver m_trailing; PendingTrailingDecisionObserver m_trailing_decision; OperationalState m_operational_state; GeometryObserver m_geometry; LayerEngineObserver m_layer; ExitEngineObserver m_exit; bool m_initialized; int m_magic;
 void UpdateTrailingObserver(PendingState &p){m_trailing.EvaluateAll(p,m_market.Bid(),m_market.Ask());int tickets[ZGOLD_TRAIL_MAX];int types[ZGOLD_TRAIL_MAX];double deltas[ZGOLD_TRAIL_MAX];string classes[ZGOLD_TRAIL_MAX];bool valids[ZGOLD_TRAIL_MAX];for(int i=0;i<ZGOLD_TRAIL_MAX;i++){tickets[i]=m_trailing.Ticket(i);types[i]=m_trailing.Type(i);deltas[i]=m_trailing.Delta(i);classes[i]=m_trailing.DistanceClass(i);valids[i]=m_trailing.Valid(i);}m_panel.SetTrailingInventory(m_trailing.Count(),tickets,types,deltas,classes,valids);}
 void UpdateDecisionObserver(PendingState &p){m_trailing_decision.Evaluate(p,m_trailing,m_market.Bid(),m_market.Ask());m_panel.SetDecisionAction(m_trailing_decision.DecisionText(m_trailing),m_trailing_decision.ActionText(m_trailing),m_trailing_decision.ReasonText(m_trailing),m_trailing_decision.DecisionTicket(m_trailing));}
 void UpdateGeometryObserver(PendingState &p,ExposureState &e){double candidate=0.0;int direction=-1;int ticket=m_trailing_decision.DecisionTicket(m_trailing);if(ticket>=0){for(int i=0;i<p.Count();i++)if(p.Ticket(i)==ticket){candidate=p.Price(i);direction=(p.Type(i)==OP_BUYSTOP?OP_BUY:OP_SELL);break;}}m_geometry.Evaluate(candidate,direction,e,p);m_panel.SetGeometry(m_geometry.Status(),m_geometry.Reason(),m_geometry.Candidate(),m_geometry.StepDistance(),m_geometry.TwoStepDistance());}
 void UpdateLayerObserver(ExposureState &e,PendingState &p){m_layer.Evaluate(e,p);m_panel.SetLayer(m_layer.BuyState(),m_layer.SellState(),m_layer.BuyRegime(),m_layer.SellRegime(),m_layer.BuyMin(),m_layer.BuyMax(),m_layer.SellMin(),m_layer.SellMax(),m_layer.BuyReference(),m_layer.SellReference());}
 void UpdateExitObserver(ExposureState &e){m_exit.Evaluate(e,m_magic);string text="NONE";string reason="NO EXIT TRIGGER";double value=m_exit.TotalProfit();double target=0.0;double result=m_exit.CompressionResult();int ticket=-1;int loss1=-1;int loss2=-1;if(m_exit.BasketTriggered()){text="BASKET";reason="DIRECTIONAL PROFIT >= COUNT*20";value=m_exit.BasketProfit();target=m_exit.BasketTarget();}else if(m_exit.CompressionTriggered()){text="COMPRESSION";reason="WINNER + 2 WORST | EXPOSURE GATE";value=m_exit.WinnerProfit();ticket=m_exit.WinnerTicket();loss1=m_exit.Loss1Ticket();loss2=m_exit.Loss2Ticket();}else if(m_exit.GlobalTriggered()){text="GLOBAL EXIT";reason="TOTAL PROFIT >= 4";}m_panel.SetExit(text,reason,value,target,result,ticket,loss1,loss2);}
 void UpdatePanel(){ExposureState e;PendingState p;m_reconciler.CopyExposureTo(e);m_reconciler.CopyPendingTo(p);m_operational_state.Evaluate(e,p);m_panel.SetMarket(m_market.Bid(),m_market.Ask(),m_market.SpreadPoints(),m_market.ServerTime());m_panel.SetExposure(e.BuyCount(),e.BuyLots(),e.BuyProfit(),e.SellCount(),e.SellLots(),e.SellProfit(),e.TotalProfit());m_panel.SetPending(p);m_panel.SetOperationalState(m_operational_state.State(),m_operational_state.Reason());m_panel.SetLifecycle(m_reconciler.LifecycleEvent(),m_reconciler.LifecycleTicket(),m_reconciler.LifecyclePreviousType(),m_reconciler.LifecycleType(),m_reconciler.LifecyclePreviousLots(),m_reconciler.LifecycleLots(),m_reconciler.LifecyclePreviousPrice(),m_reconciler.LifecyclePrice(),m_reconciler.LifecycleText());UpdateTrailingObserver(p);UpdateDecisionObserver(p);UpdateGeometryObserver(p,e);UpdateLayerObserver(e,p);UpdateExitObserver(e);}
public:
 EAController(){m_initialized=false;m_magic=1001;}
 void SetMagic(int magic){m_magic=magic;m_reconciler.SetMagic(magic);}
 int Initialize(){m_panel.Initialize();m_panel.SetModuleStatus("CORE",true);m_panel.SetModuleStatus("MARKET STATE",true);m_panel.SetModuleStatus("STATE RECONCILER",true);m_panel.SetModuleStatus("PENDING TRAILING",true);m_panel.SetModuleStatus("OPERATIONAL STATE",true);m_panel.SetModuleStatus("DECISION OBSERVER",true);m_panel.SetModuleStatus("CANDIDATE OBSERVER",true);m_panel.SetModuleStatus("GEOMETRY OBSERVER",true);m_panel.SetModuleStatus("LAYER ENGINE OBSERVER",true);m_panel.SetModuleStatus("EXIT ENGINE OBSERVER",true);m_panel.SetLastEvent("EA initialized");m_reconciler.SetMagic(m_magic);m_market.Update();m_reconciler.Reconcile();UpdatePanel();m_panel.SetRuntimeState("RUNNING");m_panel.SetLastEvent(m_reconciler.LifecycleText());m_panel.Render();Print("[ZGOLD] Exit Engine Observer block initialized");m_initialized=true;return INIT_SUCCEEDED;}
 void ProcessTick(){if(!m_initialized)return;m_market.Update();m_reconciler.Reconcile();m_panel.IncrementTick();UpdatePanel();m_panel.SetLastEvent(m_reconciler.LifecycleText());m_panel.Render();}
 void Shutdown(const int reason){m_panel.SetRuntimeState("STOPPED");m_panel.SetLastEvent("EA deinitialized");m_panel.Render();m_panel.Destroy();Print("[ZGOLD] Debug Panel removed. Reason=",reason);m_initialized=false;}
};
#endif
