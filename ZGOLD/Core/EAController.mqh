#ifndef __ZGOLD_EA_CONTROLLER_MQH__
#define __ZGOLD_EA_CONTROLLER_MQH__
#include "../State/MarketState.mqh"
#include "../State/StateReconciler.mqh"
#include "../Debug/DebugPanel.mqh"
#include "../Engine/PendingTrailingObserver.mqh"
class EAController
{
private:
 MarketState m_market; StateReconciler m_reconciler; DebugPanel m_panel; PendingTrailingObserver m_trailing; bool m_initialized; int m_magic;
 void UpdateTrailingObserver(PendingState &p){m_trailing.Reset();if(p.Count()>0)m_trailing.Evaluate(p.Ticket(0),p.Type(0),p.Price(0),m_market.Bid(),m_market.Ask());m_panel.SetTrailing(m_trailing.Ticket(),m_trailing.Type(),m_trailing.OOP(),m_trailing.MarketReference(),m_trailing.Candidate(),m_trailing.Delta(),m_trailing.DistanceClass(),m_trailing.Valid(),m_trailing.Reason());}
 void UpdatePanel(){ExposureState e;PendingState p;m_reconciler.CopyExposureTo(e);m_reconciler.CopyPendingTo(p);m_panel.SetMarket(m_market.Bid(),m_market.Ask(),m_market.SpreadPoints(),m_market.ServerTime());m_panel.SetExposure(e.BuyCount(),e.BuyLots(),e.BuyProfit(),e.SellCount(),e.SellLots(),e.SellProfit(),e.TotalProfit());m_panel.SetPending(p);m_panel.SetLifecycle(m_reconciler.LifecycleEvent(),m_reconciler.LifecycleTicket(),m_reconciler.LifecyclePreviousType(),m_reconciler.LifecycleType(),m_reconciler.LifecyclePreviousLots(),m_reconciler.LifecycleLots(),m_reconciler.LifecyclePreviousPrice(),m_reconciler.LifecyclePrice(),m_reconciler.LifecycleText());UpdateTrailingObserver(p);}
public:
 EAController(){m_initialized=false;m_magic=1001;}
 void SetMagic(int magic){m_magic=magic;m_reconciler.SetMagic(magic);}
 int Initialize(){m_panel.Initialize();m_panel.SetModuleStatus("CORE",true);m_panel.SetModuleStatus("MARKET STATE",true);m_panel.SetModuleStatus("STATE RECONCILER",true);m_panel.SetModuleStatus("PENDING TRAILING",true);m_panel.SetLastEvent("EA initialized");m_reconciler.SetMagic(m_magic);m_market.Update();m_reconciler.Reconcile();UpdatePanel();m_panel.SetRuntimeState("RUNNING");m_panel.SetLastEvent(m_reconciler.LifecycleText());m_panel.Render();Print("[ZGOLD] Fragment 07 initialized - trailing telemetry");m_initialized=true;return INIT_SUCCEEDED;}
 void ProcessTick(){if(!m_initialized)return;m_market.Update();m_reconciler.Reconcile();m_panel.IncrementTick();UpdatePanel();m_panel.SetLastEvent(m_reconciler.LifecycleText());m_panel.Render();}
 void Shutdown(const int reason){m_panel.SetRuntimeState("STOPPED");m_panel.SetLastEvent("EA deinitialized");m_panel.Render();m_panel.Destroy();Print("[ZGOLD] Debug Panel removed. Reason=",reason);m_initialized=false;}
};
#endif
