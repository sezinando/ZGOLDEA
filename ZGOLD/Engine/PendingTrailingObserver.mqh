#ifndef __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__
#define __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__

#include "../State/PendingState.mqh"

#define ZGOLD_TRAIL_NONE 0
#define ZGOLD_TRAIL_BUY  1
#define ZGOLD_TRAIL_SELL 2
#define ZGOLD_TRAIL_MAX  6

class PendingTrailingObserver
{
private:
   int    m_count;
   int    m_ticket[ZGOLD_TRAIL_MAX];
   int    m_type[ZGOLD_TRAIL_MAX];
   double m_oop[ZGOLD_TRAIL_MAX];
   double m_market_ref[ZGOLD_TRAIL_MAX];
   double m_candidate[ZGOLD_TRAIL_MAX];
   double m_delta[ZGOLD_TRAIL_MAX];
   string m_distance_class[ZGOLD_TRAIL_MAX];
   bool   m_valid[ZGOLD_TRAIL_MAX];
   string m_reason[ZGOLD_TRAIL_MAX];

   string TypeName(int type) const
   {
      if(type == OP_BUYSTOP) return "BUY STOP";
      if(type == OP_SELLSTOP) return "SELL STOP";
      return "UNKNOWN";
   }

   void EvaluateOne(int index,int ticket,int type,double oop,double bid,double ask)
   {
      m_ticket[index] = ticket;
      m_type[index] = type;
      m_oop[index] = oop;
      m_market_ref[index] = 0.0;
      m_candidate[index] = 0.0;
      m_delta[index] = 0.0;
      m_distance_class[index] = "UNRESOLVED";
      m_valid[index] = false;
      m_reason[index] = "UNRESOLVED TYPE";

      if(type == OP_BUYSTOP)
      {
         m_market_ref[index] = ask;
         m_delta[index] = oop - ask;
         m_candidate[index] = ask;
         if(MathAbs(m_delta[index] - 1.60) <= Point * 2.0)
            m_distance_class[index] = "FIRSTSTEP 1.60";
         else if(MathAbs(m_delta[index] - 3.40) <= Point * 2.0)
            m_distance_class[index] = "MINDISTANCE 3.40";
         m_valid[index] = (m_delta[index] >= 0.0);
         m_reason[index] = "BUY STOP reference = ASK";
      }
      else if(type == OP_SELLSTOP)
      {
         m_market_ref[index] = bid;
         m_delta[index] = bid - oop;
         m_candidate[index] = bid;
         if(MathAbs(m_delta[index] - 1.60) <= Point * 2.0)
            m_distance_class[index] = "FIRSTSTEP 1.60";
         else if(MathAbs(m_delta[index] - 3.40) <= Point * 2.0)
            m_distance_class[index] = "MINDISTANCE 3.40";
         m_valid[index] = (m_delta[index] >= 0.0);
         m_reason[index] = "SELL STOP reference = BID";
      }
   }

public:
   PendingTrailingObserver() { Reset(); }

   void Reset()
   {
      m_count = 0;
      for(int i = 0; i < ZGOLD_TRAIL_MAX; i++)
      {
         m_ticket[i] = -1;
         m_type[i] = -1;
         m_oop[i] = 0.0;
         m_market_ref[i] = 0.0;
         m_candidate[i] = 0.0;
         m_delta[i] = 0.0;
         m_distance_class[i] = "UNRESOLVED";
         m_valid[i] = false;
         m_reason[i] = "NO PENDING";
      }
   }

   void EvaluateAll(PendingState &p,double bid,double ask)
   {
      Reset();
      int total = p.Count();
      if(total > ZGOLD_TRAIL_MAX)
         total = ZGOLD_TRAIL_MAX;

      for(int i = 0; i < total; i++)
         EvaluateOne(i,p.Ticket(i),p.Type(i),p.Price(i),bid,ask);

      m_count = total;
   }

   int Count() const { return m_count; }
   int Ticket(int index) const { if(index < 0 || index >= m_count) return -1; return m_ticket[index]; }
   int Type(int index) const { if(index < 0 || index >= m_count) return -1; return m_type[index]; }
   double OOP(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_oop[index]; }
   double MarketReference(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_market_ref[index]; }
   double Candidate(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_candidate[index]; }
   double Delta(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_delta[index]; }
   string DistanceClass(int index) const { if(index < 0 || index >= m_count) return "-"; return m_distance_class[index]; }
   bool Valid(int index) const { if(index < 0 || index >= m_count) return false; return m_valid[index]; }
   string Reason(int index) const { if(index < 0 || index >= m_count) return "-"; return m_reason[index]; }
   string TypeText(int index) const { return TypeName(Type(index)); }
};

#endif
