#ifndef __ZGOLD_CAUSAL_TRANSITION_OBSERVER_MQH__
#define __ZGOLD_CAUSAL_TRANSITION_OBSERVER_MQH__

#include "../State/LifecycleState.mqh"
#include "../State/PendingState.mqh"

#define ZGOLD_CAUSAL_NONE        0
#define ZGOLD_CAUSAL_OBSERVED    1
#define ZGOLD_CAUSAL_UNRESOLVED  2

class CausalTransitionObserver
{
private:
   int    m_last_buy_execution_ticket;
   int    m_last_sell_execution_ticket;
   double m_last_buy_execution_price;
   double m_last_sell_execution_price;
   double m_last_buy_candidate_distance;
   double m_last_sell_candidate_distance;
   string m_buy_family;
   string m_sell_family;
   string m_reason;
   int    m_event_count;

   string Family(double distance)
   {
      if(distance <= 0.0) return "NO_REFERENCE";
      if(MathAbs(distance-0.80) <= 0.08) return "~0.80";
      if(MathAbs(distance-0.90) <= 0.08) return "~0.90";
      if(MathAbs(distance-1.60) <= 0.08) return "~1.60";
      if(MathAbs(distance-3.40) <= 0.12) return "~3.40";
      return "OTHER";
   }

public:
   CausalTransitionObserver(){Reset();}

   void Reset()
   {
      m_last_buy_execution_ticket=-1;
      m_last_sell_execution_ticket=-1;
      m_last_buy_execution_price=0.0;
      m_last_sell_execution_price=0.0;
      m_last_buy_candidate_distance=0.0;
      m_last_sell_candidate_distance=0.0;
      m_buy_family="NO_REFERENCE";
      m_sell_family="NO_REFERENCE";
      m_reason="WAITING FOR EXECUTION/CANDIDATE TRANSITION";
      m_event_count=0;
   }

   void Evaluate(int lifecycle_event,int lifecycle_ticket,int lifecycle_type,double lifecycle_price,
                 PendingState &p)
   {
      m_reason="NO NEW CAUSAL TRANSITION";

      if(lifecycle_event==ZGOLD_LIFE_EXECUTED)
      {
         if(lifecycle_type==OP_BUY)
         {
            m_last_buy_execution_ticket=lifecycle_ticket;
            m_last_buy_execution_price=lifecycle_price;
         }
         else if(lifecycle_type==OP_SELL)
         {
            m_last_sell_execution_ticket=lifecycle_ticket;
            m_last_sell_execution_price=lifecycle_price;
         }
      }

      // We use the currently visible pending orders as candidates only.
      // This observer does not promote the candidate into an execution rule.
      for(int i=0;i<p.Count();i++)
      {
         int type=p.Type(i);
         double candidate=p.Price(i);
         if(type==OP_BUYSTOP && m_last_buy_execution_price>0.0)
         {
            m_last_buy_candidate_distance=MathAbs(candidate-m_last_buy_execution_price);
            m_buy_family=Family(m_last_buy_candidate_distance);
         }
         else if(type==OP_SELLSTOP && m_last_sell_execution_price>0.0)
         {
            m_last_sell_candidate_distance=MathAbs(candidate-m_last_sell_execution_price);
            m_sell_family=Family(m_last_sell_candidate_distance);
         }
      }

      if(lifecycle_event==ZGOLD_LIFE_EXECUTED)
      {
         m_event_count++;
         m_reason="LAST SAME-DIRECTION EXECUTION UPDATED; CANDIDATE DISTANCE OBSERVED";
      }
   }

   int EventCount() const{return m_event_count;}
   int LastBuyExecutionTicket() const{return m_last_buy_execution_ticket;}
   int LastSellExecutionTicket() const{return m_last_sell_execution_ticket;}
   double LastBuyExecutionPrice() const{return m_last_buy_execution_price;}
   double LastSellExecutionPrice() const{return m_last_sell_execution_price;}
   double LastBuyCandidateDistance() const{return m_last_buy_candidate_distance;}
   double LastSellCandidateDistance() const{return m_last_sell_candidate_distance;}
   string BuyFamily() const{return m_buy_family;}
   string SellFamily() const{return m_sell_family;}
   string Reason() const{return m_reason;}
};

#endif
