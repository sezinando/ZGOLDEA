#ifndef __ZGOLD_BASKET_DECISION_OBSERVER_MQH__
#define __ZGOLD_BASKET_DECISION_OBSERVER_MQH__

#include "BasketEngine.mqh"

#define ZGOLD_BASKET_DECISION_NONE 0
#define ZGOLD_BASKET_DECISION_CLOSE 1

class BasketDecisionObserver
{
private:
   int m_decision;
   int m_direction;
   int m_count;
   double m_profit;
   double m_target;
   string m_reason;

public:
   BasketDecisionObserver(){Reset();}
   void Reset(){m_decision=ZGOLD_BASKET_DECISION_NONE;m_direction=ZGOLD_BASKET_NONE;m_count=0;m_profit=0.0;m_target=0.0;m_reason="NO BASKET DECISION";}
   void Evaluate(BasketEngine &b)
   {
      Reset();
      if(!b.Triggered()) return;
      m_decision=ZGOLD_BASKET_DECISION_CLOSE;
      m_direction=b.Direction();
      m_count=b.Count();
      m_profit=b.Profit();
      m_target=b.Target();
      m_reason="BASKET TARGET REACHED";
   }
   int Decision() const{return m_decision;}
   int Direction() const{return m_direction;}
   int Count() const{return m_count;}
   double Profit() const{return m_profit;}
   double Target() const{return m_target;}
   string Reason() const{return m_reason;}
   string Action() const{return (m_decision==ZGOLD_BASKET_DECISION_CLOSE?"CLOSE_BASKET":"NONE");}
};

#endif
