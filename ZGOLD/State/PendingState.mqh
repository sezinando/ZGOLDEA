#ifndef __ZGOLD_PENDING_STATE_MQH__
#define __ZGOLD_PENDING_STATE_MQH__

#define ZGOLD_PENDING_NONE      0
#define ZGOLD_PENDING_BUY_STOP  1
#define ZGOLD_PENDING_SELL_STOP 2
#define ZGOLD_PENDING_BUY_LIMIT 3
#define ZGOLD_PENDING_SELL_LIMIT 4

class PendingState
{
private:
   int    m_buy_stop_count;
   int    m_sell_stop_count;
   int    m_buy_limit_count;
   int    m_sell_limit_count;

   int    m_buy_stop_ticket;
   int    m_sell_stop_ticket;
   double m_buy_stop_lots;
   double m_sell_stop_lots;
   double m_buy_stop_price;
   double m_sell_stop_price;

public:
   PendingState()
   {
      Reset();
   }

   void Reset()
   {
      m_buy_stop_count = 0;
      m_sell_stop_count = 0;
      m_buy_limit_count = 0;
      m_sell_limit_count = 0;
      m_buy_stop_ticket = -1;
      m_sell_stop_ticket = -1;
      m_buy_stop_lots = 0.0;
      m_sell_stop_lots = 0.0;
      m_buy_stop_price = 0.0;
      m_sell_stop_price = 0.0;
   }

   void AddBuyStop(int ticket, double lots, double price)
   {
      m_buy_stop_count++;
      m_buy_stop_ticket = ticket;
      m_buy_stop_lots += lots;
      m_buy_stop_price = price;
   }

   void AddSellStop(int ticket, double lots, double price)
   {
      m_sell_stop_count++;
      m_sell_stop_ticket = ticket;
      m_sell_stop_lots += lots;
      m_sell_stop_price = price;
   }

   void AddBuyLimit()
   {
      m_buy_limit_count++;
   }

   void AddSellLimit()
   {
      m_sell_limit_count++;
   }

   int BuyStopCount() const { return m_buy_stop_count; }
   int SellStopCount() const { return m_sell_stop_count; }
   int BuyLimitCount() const { return m_buy_limit_count; }
   int SellLimitCount() const { return m_sell_limit_count; }

   int BuyStopTicket() const { return m_buy_stop_ticket; }
   int SellStopTicket() const { return m_sell_stop_ticket; }
   double BuyStopLots() const { return m_buy_stop_lots; }
   double SellStopLots() const { return m_sell_stop_lots; }
   double BuyStopPrice() const { return m_buy_stop_price; }
   double SellStopPrice() const { return m_sell_stop_price; }
};

#endif
