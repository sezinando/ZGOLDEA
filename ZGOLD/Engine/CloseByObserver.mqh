#ifndef __ZGOLD_CLOSEBY_OBSERVER_MQH__
#define __ZGOLD_CLOSEBY_OBSERVER_MQH__

#define ZGOLD_CLOSEBY_NONE       0
#define ZGOLD_CLOSEBY_PAIR       1
#define ZGOLD_CLOSEBY_RESIDUAL   2
#define ZGOLD_CLOSEBY_END        3

#define ZGOLD_CLOSEBY_MAX_POS 64

class CloseByObserver
{
private:
   int    m_buy_ticket;
   double m_buy_lots;
   int    m_sell_ticket;
   double m_sell_lots;
   double m_residual_lots;
   int    m_residual_direction;
   int    m_status;
   string m_reason;

public:
   CloseByObserver(){Reset();}

   void Reset()
   {
      m_buy_ticket=-1;
      m_buy_lots=0.0;
      m_sell_ticket=-1;
      m_sell_lots=0.0;
      m_residual_lots=0.0;
      m_residual_direction=-1;
      m_status=ZGOLD_CLOSEBY_NONE;
      m_reason="NO PAIR";
   }

   void Evaluate(int magic)
   {
      Reset();
      int highest_buy=-1, highest_sell=-1;
      double buy_lots=0.0, sell_lots=0.0;

      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         if(OrderType()==OP_BUY)
         {
            if(OrderTicket()>highest_buy)
            {
               highest_buy=OrderTicket();
               buy_lots=OrderLots();
            }
         }
         else if(OrderType()==OP_SELL)
         {
            if(OrderTicket()>highest_sell)
            {
               highest_sell=OrderTicket();
               sell_lots=OrderLots();
            }
         }
      }

      if(highest_buy<0 || highest_sell<0)
      {
         m_status=ZGOLD_CLOSEBY_END;
         m_reason="NO ACTIVE BUY/SELL PAIR";
         return;
      }

      m_buy_ticket=highest_buy;
      m_buy_lots=buy_lots;
      m_sell_ticket=highest_sell;
      m_sell_lots=sell_lots;
      m_residual_lots=MathAbs(buy_lots-sell_lots);

      if(m_residual_lots>0.0)
      {
         m_status=ZGOLD_CLOSEBY_RESIDUAL;
         m_residual_direction=(buy_lots>sell_lots?OP_BUY:OP_SELL);
         m_reason="CLOSEBY -> RESIDUAL NEW TICKET";
      }
      else
      {
         m_status=ZGOLD_CLOSEBY_PAIR;
         m_reason="CLOSEBY EQUAL LOTS";
      }
   }

   int Status() const{return m_status;}
   int BuyTicket() const{return m_buy_ticket;}
   double BuyLots() const{return m_buy_lots;}
   int SellTicket() const{return m_sell_ticket;}
   double SellLots() const{return m_sell_lots;}
   double ResidualLots() const{return m_residual_lots;}
   int ResidualDirection() const{return m_residual_direction;}
   string Reason() const{return m_reason;}
};

#endif
