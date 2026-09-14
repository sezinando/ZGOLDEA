#ifndef __ZGOLD_STATE_RECONCILER_MQH__
#define __ZGOLD_STATE_RECONCILER_MQH__

#include "ExposureState.mqh"

class StateReconciler
{
private:
   ExposureState m_exposure;

public:
   bool Reconcile()
   {
      int buy_count = 0;
      int sell_count = 0;
      double buy_lots = 0.0;
      double sell_lots = 0.0;
      double buy_profit = 0.0;
      double sell_profit = 0.0;

      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
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
      }

      m_exposure.Reset();
      m_exposure.SetBuy(buy_count, buy_lots, buy_profit);
      m_exposure.SetSell(sell_count, sell_lots, sell_profit);
      m_exposure.Finalize();

      return true;
   }

   ExposureState GetExposure() const
   {
      return m_exposure;
   }
};

#endif
