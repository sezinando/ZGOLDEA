#ifndef __ZGOLD_PENDING_TRAILING_EXECUTION_OBSERVER_MQH__
#define __ZGOLD_PENDING_TRAILING_EXECUTION_OBSERVER_MQH__

#include "PendingTrailingObserver.mqh"
#include "PendingTrailingDecisionObserver.mqh"
#include "../Config/ZGoldParams.mqh"

#define ZGOLD_TRAIL_EXEC_NONE       0
#define ZGOLD_TRAIL_EXEC_MODIFY     1
#define ZGOLD_TRAIL_EXEC_UNRESOLVED 2

class PendingTrailingExecutionObserver
{
private:
   int    m_status;
   int    m_ticket;
   int    m_type;
   double m_current_price;
   double m_market_reference;
   double m_distance;
   double m_candidate_price;
   string m_distance_class;
   string m_reason;

public:
   PendingTrailingExecutionObserver(){Reset();}

   void Reset()
   {
      m_status=ZGOLD_TRAIL_EXEC_NONE;
      m_ticket=-1;
      m_type=-1;
      m_current_price=0.0;
      m_market_reference=0.0;
      m_distance=0.0;
      m_candidate_price=0.0;
      m_distance_class="UNRESOLVED";
      m_reason="NO TRAILING EXECUTION";
   }

   void Evaluate(PendingState &p,
                 PendingTrailingObserver &trail,
                 PendingTrailingDecisionObserver &decision,
                 double bid,
                 double ask)
   {
      Reset();

      int ticket=decision.DecisionTicket(trail);
      if(ticket<0)
         return;

      int index=-1;
      for(int i=0;i<p.Count();i++)
      {
         if(p.Ticket(i)==ticket)
         {
            index=i;
            break;
         }
      }

      if(index<0)
      {
         m_status=ZGOLD_TRAIL_EXEC_UNRESOLVED;
         m_reason="DECISION TICKET NOT IN CURRENT PENDING INVENTORY";
         return;
      }

      m_ticket=ticket;
      m_type=p.Type(index);
      m_current_price=p.Price(index);
      m_market_reference=(m_type==OP_BUYSTOP?ask:bid);
      m_distance=trail.Delta(index);
      m_distance_class=trail.DistanceClass(index);

      double first_step=ZGoldParams::FirstStep();
      double min_distance=ZGoldParams::MinDistance();

      if(m_type==OP_BUYSTOP && m_distance_class==ZGOLD_TRAIL_FAMILY_FIRSTSTEP)
      {
         m_candidate_price=NormalizeDouble(ask+first_step,Digits);
         m_status=ZGOLD_TRAIL_EXEC_MODIFY;
         m_reason="BUY STOP -> ASK + FirstStep";
      }
      else if(m_type==OP_BUYSTOP && m_distance_class==ZGOLD_TRAIL_FAMILY_MINDISTANCE)
      {
         m_candidate_price=NormalizeDouble(ask+min_distance,Digits);
         m_status=ZGOLD_TRAIL_EXEC_MODIFY;
         m_reason="BUY STOP -> ASK + MinDistance";
      }
      else if(m_type==OP_SELLSTOP && m_distance_class==ZGOLD_TRAIL_FAMILY_FIRSTSTEP)
      {
         m_candidate_price=NormalizeDouble(bid-first_step,Digits);
         m_status=ZGOLD_TRAIL_EXEC_MODIFY;
         m_reason="SELL STOP -> BID - FirstStep";
      }
      else if(m_type==OP_SELLSTOP && m_distance_class==ZGOLD_TRAIL_FAMILY_MINDISTANCE)
      {
         m_candidate_price=NormalizeDouble(bid-min_distance,Digits);
         m_status=ZGOLD_TRAIL_EXEC_MODIFY;
         m_reason="SELL STOP -> BID - MinDistance";
      }
      else
      {
         m_status=ZGOLD_TRAIL_EXEC_UNRESOLVED;
         m_reason="DISTANCE CLASS UNRESOLVED";
      }
   }

   int Status() const{return m_status;}
   int Ticket() const{return m_ticket;}
   int Type() const{return m_type;}
   double CurrentPrice() const{return m_current_price;}
   double MarketReference() const{return m_market_reference;}
   double Distance() const{return m_distance;}
   double CandidatePrice() const{return m_candidate_price;}
   string DistanceClass() const{return m_distance_class;}
   string Reason() const{return m_reason;}
};

#endif
