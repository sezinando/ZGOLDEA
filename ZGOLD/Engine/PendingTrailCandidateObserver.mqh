#ifndef __ZGOLD_PENDING_TRAIL_CANDIDATE_OBSERVER_MQH__
#define __ZGOLD_PENDING_TRAIL_CANDIDATE_OBSERVER_MQH__

#include "PendingTrailingObserver.mqh"

#define ZGOLD_CANDIDATE_MAX 6

class PendingTrailCandidateObserver
{
private:
   int    m_count;
   int    m_ticket[ZGOLD_CANDIDATE_MAX];
   double m_candidate[ZGOLD_CANDIDATE_MAX];
   bool   m_valid[ZGOLD_CANDIDATE_MAX];
   string m_reason[ZGOLD_CANDIDATE_MAX];

public:
   PendingTrailCandidateObserver() { Reset(); }

   void Reset()
   {
      m_count = 0;
      for(int i = 0; i < ZGOLD_CANDIDATE_MAX; i++)
      {
         m_ticket[i] = -1;
         m_candidate[i] = 0.0;
         m_valid[i] = false;
         m_reason[i] = "NO PENDING";
      }
   }

   void Evaluate(PendingState &p, PendingTrailingObserver &trail)
   {
      Reset();
      int total = p.Count();
      if(total > ZGOLD_CANDIDATE_MAX) total = ZGOLD_CANDIDATE_MAX;
      m_count = total;

      for(int i = 0; i < total; i++)
      {
         m_ticket[i] = p.Ticket(i);

         if(p.Type(i) == OP_BUYSTOP && trail.Valid(i))
         {
            double delta = trail.Delta(i);
            if(MathAbs(delta - 1.60) <= Point * 2.0)
            {
               m_candidate[i] = trail.MarketReference(i) + 1.60;
               m_valid[i] = true;
               m_reason[i] = "ASK + FIRSTSTEP";
            }
            else if(MathAbs(delta - 3.40) <= Point * 2.0)
            {
               m_candidate[i] = trail.MarketReference(i) + 3.40;
               m_valid[i] = true;
               m_reason[i] = "ASK + MINDISTANCE";
            }
            else
               m_reason[i] = "UNRESOLVED DISTANCE";
         }
         else if(p.Type(i) == OP_SELLSTOP && trail.Valid(i))
         {
            double delta = trail.Delta(i);
            if(MathAbs(delta - 1.60) <= Point * 2.0)
            {
               m_candidate[i] = trail.MarketReference(i) - 1.60;
               m_valid[i] = true;
               m_reason[i] = "BID - FIRSTSTEP";
            }
            else if(MathAbs(delta - 3.40) <= Point * 2.0)
            {
               m_candidate[i] = trail.MarketReference(i) - 3.40;
               m_valid[i] = true;
               m_reason[i] = "BID - MINDISTANCE";
            }
            else
               m_reason[i] = "UNRESOLVED DISTANCE";
         }
         else
            m_reason[i] = "INVALID PENDING";
      }
   }

   int Count() const { return m_count; }
   int Ticket(int index) const { if(index < 0 || index >= m_count) return -1; return m_ticket[index]; }
   double Candidate(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_candidate[index]; }
   bool Valid(int index) const { if(index < 0 || index >= m_count) return false; return m_valid[index]; }
   string Reason(int index) const { if(index < 0 || index >= m_count) return "-"; return m_reason[index]; }
};

#endif
