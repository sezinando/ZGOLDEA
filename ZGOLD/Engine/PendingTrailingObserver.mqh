#ifndef __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__
#define __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__

#define ZGOLD_TRAIL_NONE 0
#define ZGOLD_TRAIL_BUY  1
#define ZGOLD_TRAIL_SELL 2

class PendingTrailingObserver
{
private:
   int    m_ticket;
   int    m_type;
   double m_oop;
   double m_market_ref;
   double m_candidate;
   double m_delta;
   string m_distance_class;
   bool   m_valid;
   string m_reason;

   string TypeName(int type)
   {
      if(type == OP_BUYSTOP) return "BUY STOP";
      if(type == OP_SELLSTOP) return "SELL STOP";
      return "UNKNOWN";
   }

public:
   PendingTrailingObserver() { Reset(); }

   void Reset()
   {
      m_ticket = -1;
      m_type = -1;
      m_oop = 0.0;
      m_market_ref = 0.0;
      m_candidate = 0.0;
      m_delta = 0.0;
      m_distance_class = "UNRESOLVED";
      m_valid = false;
      m_reason = "NO PENDING";
   }

   void Evaluate(int ticket, int type, double oop, double bid, double ask)
   {
      Reset();
      m_ticket = ticket;
      m_type = type;
      m_oop = oop;

      if(type == OP_BUYSTOP)
      {
         m_market_ref = ask;
         m_delta = oop - ask;
         m_candidate = ask;
         if(MathAbs(m_delta - 1.60) <= Point * 2.0)
            m_distance_class = "FIRSTSTEP 1.60";
         else if(MathAbs(m_delta - 3.40) <= Point * 2.0)
            m_distance_class = "MINDISTANCE 3.40";
         else
            m_distance_class = "UNRESOLVED";
         m_valid = (m_delta >= 0.0);
         m_reason = "BUY STOP reference = ASK";
      }
      else if(type == OP_SELLSTOP)
      {
         m_market_ref = bid;
         m_delta = bid - oop;
         m_candidate = bid;
         if(MathAbs(m_delta - 1.60) <= Point * 2.0)
            m_distance_class = "FIRSTSTEP 1.60";
         else if(MathAbs(m_delta - 3.40) <= Point * 2.0)
            m_distance_class = "MINDISTANCE 3.40";
         else
            m_distance_class = "UNRESOLVED";
         m_valid = (m_delta >= 0.0);
         m_reason = "SELL STOP reference = BID";
      }
   }

   int Ticket() const { return m_ticket; }
   int Type() const { return m_type; }
   double OOP() const { return m_oop; }
   double MarketReference() const { return m_market_ref; }
   double Candidate() const { return m_candidate; }
   double Delta() const { return m_delta; }
   string DistanceClass() const { return m_distance_class; }
   bool Valid() const { return m_valid; }
   string Reason() const { return m_reason; }
   string TypeText() const { return TypeName(m_type); }
};

#endif
