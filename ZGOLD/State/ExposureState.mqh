#ifndef __ZGOLD_EXPOSURE_STATE_MQH__
#define __ZGOLD_EXPOSURE_STATE_MQH__

class ExposureState
{
private:
   int    m_buy_count;
   int    m_sell_count;
   double m_buy_lots;
   double m_sell_lots;
   double m_buy_profit;
   double m_sell_profit;
   double m_total_profit;

public:
   ExposureState()
   {
      Reset();
   }

   void Reset()
   {
      m_buy_count = 0;
      m_sell_count = 0;
      m_buy_lots = 0.0;
      m_sell_lots = 0.0;
      m_buy_profit = 0.0;
      m_sell_profit = 0.0;
      m_total_profit = 0.0;
   }

   void SetBuy(int count, double lots, double profit)
   {
      m_buy_count = count;
      m_buy_lots = lots;
      m_buy_profit = profit;
   }

   void SetSell(int count, double lots, double profit)
   {
      m_sell_count = count;
      m_sell_lots = lots;
      m_sell_profit = profit;
   }

   void Finalize()
   {
      m_total_profit = m_buy_profit + m_sell_profit;
   }

   int BuyCount() const { return m_buy_count; }
   int SellCount() const { return m_sell_count; }
   double BuyLots() const { return m_buy_lots; }
   double SellLots() const { return m_sell_lots; }
   double BuyProfit() const { return m_buy_profit; }
   double SellProfit() const { return m_sell_profit; }
   double TotalProfit() const { return m_total_profit; }
};

#endif
