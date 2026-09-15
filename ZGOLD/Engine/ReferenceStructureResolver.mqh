#ifndef __ZGOLD_REFERENCE_STRUCTURE_RESOLVER_MQH__
#define __ZGOLD_REFERENCE_STRUCTURE_RESOLVER_MQH__
#include "../State/ExposureState.mqh"
#include "../State/PendingState.mqh"
#include "../Config/ZGoldParams.mqh"
#define ZGOLD_REF_NONE 0
#define ZGOLD_REF_H1 1
#define ZGOLD_REF_H2 2
#define ZGOLD_REF_H3 3
#define ZGOLD_REF_H4 4
#define ZGOLD_REF_UNRESOLVED 5
class ReferenceStructureResolver
{
private:
 double m_buy_extreme,m_sell_extreme,m_buy_candidate,m_sell_candidate,m_buy_pred_h1,m_sell_pred_h1;
 string m_h1_status,m_h2_status,m_h3_status,m_h4_status,m_buy_status,m_sell_status,m_reason;
public:
 ReferenceStructureResolver(){Reset();}
 void Reset(){m_buy_extreme=0;m_sell_extreme=0;m_buy_candidate=0;m_sell_candidate=0;m_buy_pred_h1=0;m_sell_pred_h1=0;m_h1_status="NOT TESTED";m_h2_status="NOT TESTED";m_h3_status="NOT TESTED";m_h4_status="NOT TESTED";m_buy_status="UNRESOLVED";m_sell_status="UNRESOLVED";m_reason="STAGE 84: REFERENCE DISCRIMINATOR NOT PROVEN";}
 void Evaluate(ExposureState &e,PendingState &p,int magic)
 {
  Reset();
  for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=magic)continue;if(OrderType()==OP_BUY){double px=OrderOpenPrice();if(m_buy_extreme==0||px>m_buy_extreme)m_buy_extreme=px;}else if(OrderType()==OP_SELL){double px2=OrderOpenPrice();if(m_sell_extreme==0||px2<m_sell_extreme)m_sell_extreme=px2;}}
  if(e.BuyCount()>0)m_buy_status="EXTREME OBSERVED";if(e.SellCount()>0)m_sell_status="EXTREME OBSERVED";
  for(int k=0;k<p.Count();k++){if(p.Type(k)==OP_BUYSTOP)m_buy_candidate=p.Price(k);else if(p.Type(k)==OP_SELLSTOP)m_sell_candidate=p.Price(k);}
  if(m_buy_candidate>0&&m_buy_extreme>0)m_buy_pred_h1=(m_buy_candidate>m_buy_extreme?ZGoldParams::Step():ZGoldParams::MinDistance());
  if(m_sell_candidate>0&&m_sell_extreme>0)m_sell_pred_h1=(m_sell_candidate<m_sell_extreme?ZGoldParams::Step():ZGoldParams::MinDistance());
  if(m_buy_pred_h1>0||m_sell_pred_h1>0)m_h1_status="CANDIDATE PREDICTION AVAILABLE; NEEDS EVENT REPLAY";
  m_h2_status="NOT TESTABLE FROM CURRENT SNAPSHOT";m_h3_status="NOT TESTABLE FROM CURRENT SNAPSHOT";m_h4_status="NOT TESTABLE FROM CURRENT SNAPSHOT";
 }
 double BuyExtreme()const{return m_buy_extreme;} double SellExtreme()const{return m_sell_extreme;} double BuyCandidate()const{return m_buy_candidate;} double SellCandidate()const{return m_sell_candidate;} double BuyH1Distance()const{return m_buy_pred_h1;} double SellH1Distance()const{return m_sell_pred_h1;} string H1Status()const{return m_h1_status;} string H2Status()const{return m_h2_status;} string H3Status()const{return m_h3_status;} string H4Status()const{return m_h4_status;} string BuyStatus()const{return m_buy_status;} string SellStatus()const{return m_sell_status;} string Reason()const{return m_reason;}
};
#endif
