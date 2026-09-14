#ifndef __ZGOLD_MARKET_STATE_MQH__
#define __ZGOLD_MARKET_STATE_MQH__

class MarketState
{
private:
   double   m_bid;
   double   m_ask;
   double   m_spread_price;
   double   m_spread_points;
   datetime m_server_time;

public:
   MarketState()
   {
      m_bid = 0.0;
      m_ask = 0.0;
      m_spread_price = 0.0;
      m_spread_points = 0.0;
      m_server_time = 0;
   }

   void Update()
   {
      RefreshRates();
      m_bid = Bid;
      m_ask = Ask;
      m_spread_price = m_ask - m_bid;
      m_spread_points = 0.0;

      if(Point > 0.0)
         m_spread_points = m_spread_price / Point;

      m_server_time = TimeCurrent();
   }

   double Bid() const { return m_bid; }
   double Ask() const { return m_ask; }
   double SpreadPrice() const { return m_spread_price; }
   double SpreadPoints() const { return m_spread_points; }
   datetime ServerTime() const { return m_server_time; }
};

#endif
