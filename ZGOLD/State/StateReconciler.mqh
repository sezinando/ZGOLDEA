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
   StateReconciler()
   {
      m_magic = 1001;
   }

   void SetMagic(int magic)
   {
      m_magic = magic;
   }

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
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         if(OrderSymbol() != Symbol())
            continue;
         if(OrderMagicNumber() != m_magic)
            continue;

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
         else if(type == OP_BUYSTOP)
         {
            m_pending.AddBuyStop(OrderTicket(), OrderLots(), OrderOpenPrice());
         }
         else if(type == OP_SELLSTOP)
         {
            m_pending.AddSellStop(OrderTicket(), OrderLots(), OrderOpenPrice());
         }
         else if(type == OP_BUYLIMIT)
         {
            m_pending.AddBuyLimit();
         }
         else if(type == OP_SELLLIMIT)
         {
            m_pending.AddSellLimit();
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
      if(m_pending.BuyStopCount() > 0)
         target.AddBuyStop(m_pending.BuyStopTicket(), m_pending.BuyStopLots(), m_pending.BuyStopPrice());
      if(m_pending.SellStopCount() > 0)
         target.AddSellStop(m_pending.SellStopTicket(), m_pending.SellStopLots(), m_pending.SellStopPrice());
      for(int i = 1; i < m_pending.BuyLimitCount(); i++)
         target.AddBuyLimit();
      for(int i = 1; i < m_pending.SellLimitCount(); i++)
         target.AddSellLimit();
   }

   int LifecycleEvent() const { return m_lifecycle.Event(); }
   int LifecycleTicket() const { return m_lifecycle.Ticket(); }
   double LifecycleLots() const { return m_lifecycle.Lots(); }
   double LifecyclePrice() const { return m_lifecycle.Price(); }
   string LifecycleText() const { return m_lifecycle.EventText(); }
};

#endif
