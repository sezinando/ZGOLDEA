#ifndef __ZGOLD_EA_CONTROLLER_MQH__
#define __ZGOLD_EA_CONTROLLER_MQH__

#include "../State/MarketState.mqh"
#include "../State/StateReconciler.mqh"
#include "../Debug/DebugPanel.mqh"

class EAController
{
private:
   MarketState     m_market;
   StateReconciler m_reconciler;
   DebugPanel      m_panel;
   bool             m_initialized;
   int              m_magic;

   void UpdatePanel()
   {
      ExposureState exposure;
      PendingState pending;
      m_reconciler.CopyExposureTo(exposure);
      m_reconciler.CopyPendingTo(pending);

      m_panel.SetMarket(m_market.Bid(), m_market.Ask(), m_market.SpreadPoints(), m_market.ServerTime());
      m_panel.SetExposure(exposure.BuyCount(), exposure.BuyLots(), exposure.BuyProfit(),
                          exposure.SellCount(), exposure.SellLots(), exposure.SellProfit(),
                          exposure.TotalProfit());
      m_panel.SetPending(pending);
   }

public:
   EAController()
   {
      m_initialized = false;
      m_magic = 1001;
   }

   void SetMagic(int magic)
   {
      m_magic = magic;
      m_reconciler.SetMagic(magic);
   }

   int Initialize()
   {
      m_panel.Initialize();
      m_panel.SetModuleStatus("CORE", true);
      m_panel.SetModuleStatus("MARKET STATE", true);
      m_panel.SetModuleStatus("STATE RECONCILER", true);
      m_panel.SetLastEvent("EA initialized");

      m_reconciler.SetMagic(m_magic);
      m_market.Update();
      m_reconciler.Reconcile();
      UpdatePanel();

      m_panel.SetRuntimeState("RUNNING");
      m_panel.SetLastEvent(m_reconciler.LifecycleText());
      m_panel.Render();

      Print("[ZGOLD] Pending inventory + lifecycle observation initialized");
      m_initialized = true;
      return INIT_SUCCEEDED;
   }

   void ProcessTick()
   {
      if(!m_initialized) return;

      m_market.Update();
      m_reconciler.Reconcile();
      m_panel.IncrementTick();
      UpdatePanel();
      m_panel.SetLastEvent(m_reconciler.LifecycleText());
      m_panel.Render();
   }

   void Shutdown(const int reason)
   {
      m_panel.SetRuntimeState("STOPPED");
      m_panel.SetLastEvent("EA deinitialized");
      m_panel.Render();
      m_panel.Destroy();
      Print("[ZGOLD] Debug Panel removed. Reason=", reason);
      m_initialized = false;
   }
};

#endif
