#ifndef __ZGOLD_EXIT_ENGINE_OBSERVER_MQH__
#define __ZGOLD_EXIT_ENGINE_OBSERVER_MQH__

#include "../State/ExposureState.mqh"

#define ZGOLD_EXIT_NONE         0
#define ZGOLD_EXIT_BASKET       1
#define ZGOLD_EXIT_COMPRESSION  2
#define ZGOLD_EXIT_GLOBAL       3

#define ZGOLD_EXIT_MAX_POS 64

class ExitEngineObserver
{
private:
   int m_basket_direction;
   double m_basket_profit;
   double m_basket_target;
   bool m_basket_triggered;

   double m_total_profit;
   bool m_global_triggered;

   int m_compression_direction;
   int m_compression_count;
   int m_winner_ticket;
   double m_winner_profit;
   int m_loss1_ticket;
   double m_loss1_profit;
   int m_loss2_ticket;
   double m_loss2_profit;
   double m_compression_result;
   bool m_compression_triggered;

   void EvaluateDirection(int direction,int magic)
   {
      int count=0;
      double total=0.0;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         int type=OrderType();
         if((direction==OP_BUY && type!=OP_BUY) || (direction==OP_SELL && type!=OP_SELL)) continue;
         count++;
         total += OrderProfit()+OrderSwap()+OrderCommission();
      }
      if(count>0 && total >= count*20.0)
      {
         if(!m_basket_triggered || total>m_basket_profit)
         {
            m_basket_direction=direction;
            m_basket_profit=total;
            m_basket_target=count*20.0;
         }
         m_basket_triggered=true;
      }
   }

public:
   ExitEngineObserver(){Reset();}

   void Reset()
   {
      m_basket_direction=-1;
      m_basket_profit=0.0;
      m_basket_target=0.0;
      m_basket_triggered=false;
      m_total_profit=0.0;
      m_global_triggered=false;
      m_compression_direction=-1;
      m_compression_count=0;
      m_winner_ticket=-1;
      m_winner_profit=0.0;
      m_loss1_ticket=-1;
      m_loss1_profit=0.0;
      m_loss2_ticket=-1;
      m_loss2_profit=0.0;
      m_compression_result=0.0;
      m_compression_triggered=false;
   }

   void Evaluate(ExposureState &e,int magic)
   {
      Reset();
      m_total_profit=e.TotalProfit();
      m_global_triggered=(m_total_profit>=4.0);

      EvaluateDirection(OP_BUY,magic);
      EvaluateDirection(OP_SELL,magic);

      double buy_profits[ZGOLD_EXIT_MAX_POS];
      int buy_tickets[ZGOLD_EXIT_MAX_POS];
      double sell_profits[ZGOLD_EXIT_MAX_POS];
      int sell_tickets[ZGOLD_EXIT_MAX_POS];
      int buy_n=0,sell_n=0;

      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         int type=OrderType();
         double profit=OrderProfit()+OrderSwap()+OrderCommission();
         if(type==OP_BUY && buy_n<ZGOLD_EXIT_MAX_POS){buy_tickets[buy_n]=OrderTicket();buy_profits[buy_n]=profit;buy_n++;}
         else if(type==OP_SELL && sell_n<ZGOLD_EXIT_MAX_POS){sell_tickets[sell_n]=OrderTicket();sell_profits[sell_n]=profit;sell_n++;}
      }

      // Compression: winner + two worst losses, only when count > 3 and
      // directional winner is positive and the selected three realize > 0.
      for(int pass=0;pass<2;pass++)
      {
         int n=(pass==0?buy_n:sell_n);
         int &dir_ref=(pass==0?m_compression_direction:m_compression_direction);
         if(n<=3) continue;
         double *profits=NULL; int *tickets=NULL;
         if(pass==0){profits=buy_profits;tickets=buy_tickets;} else {profits=sell_profits;tickets=sell_tickets;}
         int win=0;
         for(int j=1;j<n;j++) if(profits[j]>profits[win]) win=j;
         int w1=-1,w2=-1;
         for(int j=0;j<n;j++)
         {
            if(j==win) continue;
            if(w1<0 || profits[j]<profits[w1]){w2=w1;w1=j;}
            else if(w2<0 || profits[j]<profits[w2]){w2=j;}
         }
         if(w1>=0 && w2>=0)
         {
            double result=profits[win]+profits[w1]+profits[w2];
            if(profits[win]>0.0 && result>0.0 &&
               ((pass==0?e.BuyLots():e.SellLots()) > (pass==0?e.SellLots():e.BuyLots()) + 3.0*OrderLotsByTicket(tickets[win],magic)))
            {
               if(!m_compression_triggered || result<m_compression_result)
               {
                  m_compression_direction=(pass==0?OP_BUY:OP_SELL);
                  m_compression_count=3;
                  m_winner_ticket=tickets[win]; m_winner_profit=profits[win];
                  m_loss1_ticket=tickets[w1]; m_loss1_profit=profits[w1];
                  m_loss2_ticket=tickets[w2]; m_loss2_profit=profits[w2];
                  m_compression_result=result;
               }
               m_compression_triggered=true;
            }
         }
      }
   }

   // Kept isolated so no execution side-effect exists in the observer.
   double OrderLotsByTicket(int ticket,int magic) const
   {
      if(ticket<0) return 0.0;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderTicket()==ticket) return OrderLots();
      }
      return 0.0;
   }

   bool BasketTriggered() const{return m_basket_triggered;}
   int BasketDirection() const{return m_basket_direction;}
   double BasketProfit() const{return m_basket_profit;}
   double BasketTarget() const{return m_basket_target;}
   bool GlobalTriggered() const{return m_global_triggered;}
   double TotalProfit() const{return m_total_profit;}
   bool CompressionTriggered() const{return m_compression_triggered;}
   int CompressionDirection() const{return m_compression_direction;}
   int CompressionCount() const{return m_compression_count;}
   int WinnerTicket() const{return m_winner_ticket;}
   double WinnerProfit() const{return m_winner_profit;}
   int Loss1Ticket() const{return m_loss1_ticket;}
   double Loss1Profit() const{return m_loss1_profit;}
   int Loss2Ticket() const{return m_loss2_ticket;}
   double Loss2Profit() const{return m_loss2_profit;}
   double CompressionResult() const{return m_compression_result;}
};

#endif
