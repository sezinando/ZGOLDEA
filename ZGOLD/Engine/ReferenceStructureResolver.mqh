#ifndef __ZGOLD_REFERENCE_STRUCTURE_RESOLVER_MQH__
#define __ZGOLD_REFERENCE_STRUCTURE_RESOLVER_MQH__

#include "../State/ExposureState.mqh"
#include "../State/PendingState.mqh"
#include "../Config/ZGoldParams.mqh"

#define ZGOLD_REF_NONE        0
#define ZGOLD_REF_H1          1
#define ZGOLD_REF_H2          2
#define ZGOLD_REF_H3          3
#define ZGOLD_REF_H4          4
#define ZGOLD_REF_UNRESOLVED  5

class ReferenceStructureResolver
{
private:
   double m_buy_extreme;
   double m_sell_extreme;
   double m_buy_candidate;
   double m_sell_candidate;
   double m_buy_pred_h1;
   double m_sell_pred_h1;
   string m_h1_status;
   string m_h2_status;
   string m_h3_status;
   string m_h4_status;
   string m_buy_status;
   string m_sell_status;
   string m_reason;

   bool Near(double a,double b){return MathAbs(a-b)<=Point*2.0;}

public:
   ReferenceStructureResolver(){Reset();}
   void Reset(){m_buy_extreme=0;m_sell_extreme=0;m_buy_candidate=0;m_sell_candidate=0;m_buy_pred_h1=0;m_sell_pred_h1=0;m_h1_status="NOT TESTED";m_h2_status="NOT TESTED";m_h3_status="NOT TESTED";m_h4_status="NOT TESTED";m_buy_status="UNRESOLVED";m_sell_status="UNRESOLVED";m_reason="STAGE 84: REFERENCE DISCRIMINATOR NOT PROVEN";}

   void Evaluate(ExposureState &e,PendingState &p)
   {
      Reset();
      if(e.BuyCount()>0)
      {
         for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=ZGoldParams::Magic()||OrderType()!=OP_BUY)continue;double px=OrderOpenPrice();if(m_buy_extreme==0||px>m_buy_extreme)m_buy_extreme=px;}
         m_buy_status="EXTREME OBSERVED";
      }
      if(e.SellCount()>0)
      {
         for(int j=OrdersTotal()-1;j>=0;j--){if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES))continue;if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=ZGoldParams::Magic()||OrderType()!=OP_SELL)continue;double px=OrderOpenPrice();if(m_sell_extreme==0||px<m_sell_extreme)m_sell_extreme=px;}
         m_sell_status="EXTREME OBSERVED";
      }
      for(int k=0;k<p.Count();k++)
      {
         int t=p.Type(k); double px=p.Price(k);
         if(t==OP_BUYSTOP)m_buy_candidate=px;
         else if(t==OP_SELLSTOP)m_sell_candidate=px;
      }
      // H1 is kept as an explicit test, never accepted as truth merely because it matches one tick.
      if(m_buy_candidate>0&&m_buy_extreme>0)m_buy_pred_h1=(m_buy_candidate>m_buy_extreme?ZGoldParams::Step():ZGoldParams::MinDistance());
      if(m_sell_candidate>0&&m_sell_extreme>0)m_sell_pred_h1=(m_sell_candidate<m_sell_extreme?ZGoldParams::Step():ZGoldParams::MinDistance());
      if(m_buy_pred_h1>0||m_sell_pred_h1>0)m_h1_status="CANDIDATE PREDICTION AVAILABLE; NEEDS EVENT REPLAY";
      m_h2_status="NOT TESTABLE FROM CURRENT SNAPSHOT";
      m_h3_status="NOT TESTABLE FROM CURRENT SNAPSHOT";
      m_h4_status="NOT TESTABLE FROM CURRENT SNAPSHOT";
   }

   double BuyExtreme()const{return m_buy_extreme;}
   double SellExtreme()const{return m_sell_extreme;}
   double BuyCandidate()const{return m_buy_candidate;}
   double SellCandidate()const{return m_sell_candidate;}
   double BuyH1Distance()const{return m_buy_pred_h1;}
   double SellH1Distance()const{return m_sell_pred_h1;}
   string H1Status()const{return m_h1_status;}
   string H2Status()const{return m_h2_status;}
   string H3Status()const{return m_h3_status;}
   string H4Status()const{return m_h4_status;}
   string BuyStatus()const{return m_buy_status;}
   string SellStatus()const{return m_sell_status;}
   string Reason()const{return m_reason;}
};

#endif
