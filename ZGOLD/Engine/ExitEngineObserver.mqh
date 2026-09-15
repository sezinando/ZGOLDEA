#ifndef __ZGOLD_EXIT_ENGINE_OBSERVER_MQH__
#define __ZGOLD_EXIT_ENGINE_OBSERVER_MQH__

#include "../State/ExposureState.mqh"

#define ZGOLD_EXIT_NONE         0
#define ZGOLD_EXIT_BASKET       1
#define ZGOLD_EXIT_COMPRESSION  2
#define ZGOLD_EXIT_GLOBAL       3
#define ZGOLD_EXIT_MAX_POS      64

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

   double LotsByTicket(int ticket,int magic)
   {
      if(ticket<0) return 0.0;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderTicket()==ticket)
            return OrderLots();
      }
      return 0.0;
   }

   void EvaluateBasketDirection(int direction,int magic)
   {
      int count=0;
      double profit=0.0;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         int type=OrderType();
         if((direction==OP_BUY && type!=OP_BUY) || (direction==OP_SELL && type!=OP_SELL)) continue;
         count++;
         profit += OrderProfit()+OrderSwap()+OrderCommission();
      }
      if(count>0 && profit >= count*20.0)
      {
         if(!m_basket_triggered || profit>m_basket_profit)
         {
            m_basket_direction=direction;
            m_basket_profit=profit;
            m_basket_target=count*20.0;
         }
         m_basket_triggered=true;
      }
   }

   void EvaluateCompressionDirection(int direction,int magic,double side_lots,double opposite_lots)
   {
      int tickets[ZGOLD_EXIT_MAX_POS];
      double profits[ZGOLD_EXIT_MAX_POS];
      int n=0;
      for(int i=OrdersTotal()-1;i>=0 && n<ZGOLD_EXIT_MAX_POS;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         int type=OrderType();
         if((direction==OP_BUY && type!=OP_BUY) || (direction==OP_SELL && type!=OP_SELL)) continue;
         tickets[n]=OrderTicket();
         profits[n]=OrderProfit()+OrderSwap()+OrderCommission();
         n++;
      }
      if(n<=3) return;

      int win=0;
      for(int j=1;j<n;j++) if(profits[j]>profits[win]) win=j;

      int loss1=-1;
      int loss2=-1;
      for(int k=0;k<n;k++)
      {
         if(k==win) continue;
         if(loss1<0 || profits[k]<profits[loss1])
         {
            loss2=loss1;
            loss1=k;
         }
         else if(loss2<0 || profits[k]<profits[loss2])
         {
            loss2=k;
         }
      }
      if(loss1<0 || loss2<0) return;

      double result=profits[win]+profits[loss1]+profits[loss2];
      double winner_lots=LotsByTicket(tickets[win],magic);
      if(winner_lots>0.0 && side_lots>opposite_lots+3.0*winner_lots && profits[win]>0.0 && result>0.0)
      {
         if(m_compression_direction<0 || result<m_compression_result)
         {
            m_compression_direction=direction;
            m_compression_count=3;
            m_winner_ticket=tickets[win];
            m_winner_profit=profits[win];
            m_loss1_ticket=tickets[loss1];
            m_loss1_profit=profits[loss1];
            m_loss2_ticket=tickets[loss2];
            m_loss2_profit=profits[loss2];
            m_compression_result=result;
         }
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
   }

   void Evaluate(ExposureState &e,int magic)
   {
      Reset();
      m_total_profit=e.TotalProfit();
      m_global_triggered=(m_total_profit>=4.0);
      EvaluateBasketDirection(OP_BUY,magic);
      EvaluateBasketDirection(OP_SELL,magic);
      EvaluateCompressionDirection(OP_BUY,magic,e.BuyLots(),e.SellLots());
      EvaluateCompressionDirection(OP_SELL,magic,e.SellLots(),e.BuyLots());
   }

   bool BasketTriggered() const{return m_basket_triggered;}
   int BasketDirection() const{return m_basket_direction;}
   double BasketProfit() const{return m_basket_profit;}
   double BasketTarget() const{return m_basket_target;}
   bool GlobalTriggered() const{return m_global_triggered;}
   double TotalProfit() const{return m_total_profit;}
   bool CompressionTriggered() const{return m_compression_direction>=0;}
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
