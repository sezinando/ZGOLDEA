#ifndef __ZGOLD_STATE_RECONCILER_MQH__
#define __ZGOLD_STATE_RECONCILER_MQH__

#include "ExposureState.mqh"
#include "PendingState.mqh"
#include "LifecycleState.mqh"

class StateReconciler
{
private:
   ExposureState  m_exposure;
   PendingState   m_pending;
   LifecycleState m_lifecycle;
   int            m_magic;

public:
   StateReconciler() { m_magic = 1001; }

   void SetMagic(int magic) { m_magic = magic; }

   bool Reconcile()
   {
      int buy_count = 0;
      int sell_count = 0;
      double buy_lots = 0.0;
      double sell_lots = 0.0;
      double buy_profit = 0.0;
      double sell_profit = 0.0;

      m_pending.Reset();
      m_lifecycle.Reconcile(m_magic);

      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
         if(OrderSymbol() != Symbol()) continue;
         if(OrderMagicNumber() != m_magic) continue;

         int type = OrderType();

         if(type == OP_BUY)
         {
            buy_count++;
            buy_lots += OrderLots();
            buy_profit += OrderProfit() + OrderSwap() + OrderCommission();
         }
         else if(type == OP_SELL)
         {
            sell_count++;
            sell_lots += OrderLots();
            sell_profit += OrderProfit() + OrderSwap() + OrderCommission();
         }
         else if(type == OP_BUYSTOP || type == OP_SELLSTOP ||
                 type == OP_BUYLIMIT || type == OP_SELLLIMIT)
         {
            m_pending.Add(OrderTicket(), type, OrderLots(), OrderOpenPrice());
         }
      }

      m_exposure.Reset();
      m_exposure.SetBuy(buy_count, buy_lots, buy_profit);
      m_exposure.SetSell(sell_count, sell_lots, sell_profit);
      m_exposure.Finalize();

      return true;
   }

   void CopyExposureTo(ExposureState &target)
   {
      target.Reset();
      target.SetBuy(m_exposure.BuyCount(), m_exposure.BuyLots(), m_exposure.BuyProfit());
      target.SetSell(m_exposure.SellCount(), m_exposure.SellLots(), m_exposure.SellProfit());
      target.Finalize();
   }

   void CopyPendingTo(PendingState &target)
   {
      target.Reset();
      for(int i = 0; i < m_pending.Count(); i++)
         target.Add(m_pending.Ticket(i), m_pending.Type(i), m_pending.Lots(i), m_pending.Price(i));
   }

   int LifecycleEvent() const { return m_lifecycle.Event(); }
   int LifecycleTicket() const { return m_lifecycle.Ticket(); }
   double LifecycleLots() const { return m_lifecycle.Lots(); }
   double LifecyclePrice() const { return m_lifecycle.Price(); }
   string LifecycleText() const { return m_lifecycle.EventText(); }
};

#endif
