#ifndef __ZGOLD_MARKET_STATE_MQH__
#define __ZGOLD_MARKET_STATE_MQH__

class MarketState
{
private:
   double   m_bid;
   double   m_ask;
   double   m_spread;
   datetime m_server_time;

public:
   MarketState()
   {
      m_bid = 0.0;
      m_ask = 0.0;
      m_spread = 0.0;
      m_server_time = 0;
   }

   void Update()
   {
      RefreshRates();
      m_bid = Bid;
      m_ask = Ask;
      m_spread = m_ask - m_bid;
      m_server_time = TimeCurrent();
   }

   double Bid() const { return m_bid; }
   double Ask() const { return m_ask; }
   double Spread() const { return m_spread; }
   datetime ServerTime() const { return m_server_time; }
};

#endif
