#ifndef __ZGOLD_EXECUTION_ENGINE_MQH__
#define __ZGOLD_EXECUTION_ENGINE_MQH__

#include <stdlib.mqh>
#include "../Config/ZGoldParams.mqh"
#include "ExitDecisionObserver.mqh"
#include "CloseByObserver.mqh"
#include "PendingTrailingExecutionObserver.mqh"
#include "PendingExecutionObserver.mqh"

// Stage 97: execution adapter for Strategy Tester / controlled forward test.
// The observer layer remains the source of decisions. Execution is isolated
// here so OrderSend/Modify/Close/CloseBy can be disabled without changing
// the forensic observers.

#define ZGOLD_EXEC_DISABLED 0
#define ZGOLD_EXEC_TEST     1
#define ZGOLD_EXEC_STATUS_OK 0
#define ZGOLD_EXEC_STATUS_ERROR 1

class ExecutionEngine
{
private:
   bool   m_enabled;
   int    m_magic;
   int    m_slippage;
   int    m_execution_mode;
   string m_last_action;
   string m_last_error;

public:
   ExecutionEngine(){m_enabled=false;m_magic=1001;m_slippage=20;m_execution_mode=ZGOLD_EXEC_TEST;ResetStatus();}

   void Configure(int magic,bool enabled,int execution_mode,int slippage){m_magic=magic;m_enabled=enabled;m_execution_mode=execution_mode;m_slippage=MathMax(0,slippage);}
   void ResetStatus(){m_last_action="NONE";m_last_error="";}
   bool Enabled()const{return m_enabled && m_execution_mode!=ZGOLD_EXEC_DISABLED;}
   string LastAction()const{return m_last_action;}
   string LastError()const{return m_last_error;}

   bool EnsureInitialStructure(double bid,double ask)
   {
      if(!Enabled())return false;
      if(HasMarketOrPending(OP_BUYSTOP) || HasMarketOrPending(OP_SELLSTOP))return false;
      if(CurrentPositionCount()>0 || PendingCount()>0)return false;
      if(ZGoldParams::MaxSpreadPoints()>0 && MarketInfo(Symbol(),MODE_SPREAD)>ZGoldParams::MaxSpreadPoints())
      {m_last_error="SPREAD_LIMIT";return false;}
      double buy_price=NormalizePending(OP_BUYSTOP,ask+ZGoldParams::FirstStep());
      double sell_price=NormalizePending(OP_SELLSTOP,bid-ZGoldParams::FirstStep());
      bool b=SendPending(OP_BUYSTOP,ZGoldParams::Lot(),buy_price,"ZGOLD_INIT_BUY");
      bool s=SendPending(OP_SELLSTOP,ZGoldParams::Lot(),sell_price,"ZGOLD_INIT_SELL");
      return b&&s;
   }

   bool ExecuteTrailing(PendingTrailingExecutionObserver &trail_exec)
   {
      if(!Enabled() || trail_exec.Status()!=ZGOLD_TRAIL_EXEC_MODIFY)return false;
      int ticket=trail_exec.Ticket();
      if(ticket<0 || !OrderSelect(ticket,SELECT_BY_TICKET))return false;
      if(OrderMagicNumber()!=m_magic || OrderSymbol()!=Symbol())return false;
      double price=NormalizeDouble(trail_exec.CandidatePrice(),Digits);
      if(MathAbs(OrderOpenPrice()-price)<Point*0.5)return false;
      ResetStatus();
      bool ok=OrderModify(ticket,price,OrderStopLoss(),OrderTakeProfit(),0,clrNONE);
      if(ok)m_last_action="MODIFY #"+IntegerToString(ticket)+" -> "+DoubleToString(price,Digits);
      else m_last_error="OrderModify error "+IntegerToString(GetLastError());
      return ok;
   }

   bool ExecuteExit(ExitDecisionObserver &decision,CloseByObserver &closeby)
   {
      if(!Enabled())return false;
      int d=decision.Decision();
      if(d==ZGOLD_EXIT_DEC_GLOBAL)return ExecuteGlobal(closeby);
      if(d==ZGOLD_EXIT_DEC_CLOSEBY)return ExecuteCloseBy(closeby);
      if(d==ZGOLD_EXIT_DEC_COMPRESSION)return ExecuteCompression(decision);
      if(d==ZGOLD_EXIT_DEC_BASKET)return ExecuteBasket(decision.Direction());
      return false;
   }

   bool ExecuteExpansionAfterExecution(PendingExecutionObserver &exec,double bid,double ask)
   {
      if(!Enabled() || exec.Status()!=ZGOLD_EXEC_EXECUTED)return false;
      ResetStatus();
      // Conservative reconstruction: after a market fill, restore the
      // opposing stop using the proven 3.40 family from the execution price.
      // The exact Zeus secondary same-direction 0.80 rule remains unresolved.
      if(exec.Type()==OP_BUYSTOP)
      {
         double sell_price=NormalizePending(OP_SELLSTOP,exec.Price()-ZGoldParams::MinDistance());
         if(!HasPendingType(OP_SELLSTOP))return SendPending(OP_SELLSTOP,exec.Lots(),sell_price,"ZGOLD_EXP_SELL");
      }
      else if(exec.Type()==OP_SELLSTOP)
      {
         double buy_price=NormalizePending(OP_BUYSTOP,exec.Price()+ZGoldParams::MinDistance());
         if(!HasPendingType(OP_BUYSTOP))return SendPending(OP_BUYSTOP,exec.Lots(),buy_price,"ZGOLD_EXP_BUY");
      }
      return false;
   }

   bool CleanupAndReset(double bid,double ask)
   {
      if(!Enabled())return false;
      bool changed=false;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
         if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)continue;
         int t=OrderType();
         if(t==OP_BUYSTOP||t==OP_SELLSTOP||t==OP_BUYLIMIT||t==OP_SELLLIMIT)
         {
            if(OrderDelete(OrderTicket()))changed=true;
         }
      }
      if(CurrentPositionCount()==0 && PendingCount()==0)
         if(EnsureInitialStructure(bid,ask))changed=true;
      return changed;
   }

private:
   int CurrentPositionCount()
   {
      int n=0;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
         if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)continue;
         if(OrderType()==OP_BUY||OrderType()==OP_SELL)n++;
      }
      return n;
   }

   int PendingCount()
   {
      int n=0;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
         if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)continue;
         int t=OrderType();
         if(t==OP_BUYSTOP||t==OP_SELLSTOP||t==OP_BUYLIMIT||t==OP_SELLLIMIT)n++;
      }
      return n;
   }

   bool HasPendingType(int type)
   {
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==m_magic&&OrderType()==type)return true;
      }
      return false;
   }

   bool HasMarketOrPending(int type)
   {
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
         if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)continue;
         if(OrderType()==type)return true;
      }
      return false;
   }

   double NormalizePending(int type,double requested)
   {
      double stop_level=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
      double min_dist=MathMax(stop_level,Point);
      if(type==OP_BUYSTOP && requested<=Ask+min_dist)requested=Ask+min_dist;
      if(type==OP_SELLSTOP && requested>=Bid-min_dist)requested=Bid-min_dist;
      return NormalizeDouble(requested,Digits);
   }

   double NormalizeOrderLots(double lots)
   {
      double minlot=MarketInfo(Symbol(),MODE_MINLOT);
      double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
      double step=MarketInfo(Symbol(),MODE_LOTSTEP);
      lots=MathMax(minlot,MathMin(maxlot,lots));
      if(step>0)lots=MathFloor(lots/step+0.0000001)*step;
      return NormalizeDouble(lots,ZGoldParams::DigitsLot());
   }

   bool SendPending(int type,double lots,double price,string comment)
   {
      lots=NormalizeOrderLots(lots);
      ResetLastError();
      int ticket=OrderSend(Symbol(),type,lots,price,m_slippage,0,0,comment,m_magic,0,clrNONE);
      if(ticket<0){m_last_error="OrderSend error "+IntegerToString(GetLastError());return false;}
      m_last_action="SEND #"+IntegerToString(ticket)+" "+comment+" @ "+DoubleToString(price,Digits);
      return true;
   }

   bool CloseTicket(int ticket)
   {
      if(!OrderSelect(ticket,SELECT_BY_TICKET))return false;
      if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)return false;
      int type=OrderType();
      if(type!=OP_BUY&&type!=OP_SELL)return false;
      double close_price=(type==OP_BUY?Bid:Ask);
      ResetLastError();
      if(!OrderClose(ticket,OrderLots(),close_price,m_slippage,clrNONE))
      {m_last_error="OrderClose error "+IntegerToString(GetLastError());return false;}
      m_last_action="CLOSE #"+IntegerToString(ticket);
      return true;
   }

   bool ExecuteBasket(int direction)
   {
      bool changed=false;
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
         if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)continue;
         if(OrderType()==direction)if(CloseTicket(OrderTicket()))changed=true;
      }
      return changed;
   }

   bool ExecuteCompression(ExitDecisionObserver &decision)
   {
      bool changed=false;
      int tickets[3];
      tickets[0]=decision.Ticket();tickets[1]=decision.Ticket2();tickets[2]=-1;
      // ExitDecisionObserver exposes the winner and first loss. Recover the
      // second loss by selecting the worst remaining opposite side in the
      // same direction as the winner.
      int winner=tickets[0], first_loss=tickets[1], second_loss=-1;
      if(winner>=0 && OrderSelect(winner,SELECT_BY_TICKET))
      {
         int type=OrderType(); double worst=DBL_MAX;
         for(int i=OrdersTotal()-1;i>=0;i--)
         {
            if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
            if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic||OrderType()!=type)continue;
            int t=OrderTicket();
            if(t==winner||t==first_loss)continue;
            double p=OrderProfit()+OrderSwap()+OrderCommission();
            if(p<worst){worst=p;second_loss=t;}
         }
      }
      if(CloseTicket(winner))changed=true;
      if(CloseTicket(first_loss))changed=true;
      if(CloseTicket(second_loss))changed=true;
      return changed;
   }

   bool ExecuteCloseBy(CloseByObserver &closeby)
   {
      int buy=closeby.BuyTicket(), sell=closeby.SellTicket();
      if(buy<0||sell<0)return false;
      if(!OrderSelect(buy,SELECT_BY_TICKET))return false;
      if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)return false;
      if(!OrderSelect(sell,SELECT_BY_TICKET))return false;
      if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)return false;
      ResetLastError();
      if(!OrderCloseBy(buy,sell,clrNONE))
      {m_last_error="OrderCloseBy error "+IntegerToString(GetLastError());return false;}
      m_last_action="CLOSEBY #"+IntegerToString(buy)+"/#"+IntegerToString(sell);
      return true;
   }

   bool ExecuteGlobal(CloseByObserver &closeby)
   {
      // One close-by pair per tick. Reconciliation on the next tick decides
      // whether another pair or residual cleanup is required.
      if(closeby.Status()==ZGOLD_CLOSEBY_PAIR||closeby.Status()==ZGOLD_CLOSEBY_RESIDUAL)
         return ExecuteCloseBy(closeby);
      if(closeby.Status()==ZGOLD_CLOSEBY_END)
      {
         bool changed=false;
         for(int i=OrdersTotal()-1;i>=0;i--)
         {
            if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
            if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)continue;
            if(OrderType()==OP_BUY||OrderType()==OP_SELL)if(CloseTicket(OrderTicket()))changed=true;
         }
         if(changed)return true;
         return CleanupAndReset(Bid,Ask);
      }
      return false;
   }
};

#endif
