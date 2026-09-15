#ifndef __ZGOLD_PENDING_TRAILING_DECISION_OBSERVER_MQH__
#define __ZGOLD_PENDING_TRAILING_DECISION_OBSERVER_MQH__

#include "PendingTrailingObserver.mqh"

#define ZGOLD_DECISION_NONE       0
#define ZGOLD_DECISION_HOLD       1
#define ZGOLD_DECISION_TRAIL      2

#define ZGOLD_DECISION_MAX 6

class PendingTrailingDecisionObserver
{
private:
   int    m_count;
   int    m_ticket[ZGOLD_DECISION_MAX];
   double m_reference_baseline[ZGOLD_DECISION_MAX];
   double m_current_ref[ZGOLD_DECISION_MAX];
   double m_reference_move[ZGOLD_DECISION_MAX];
   bool   m_triggered[ZGOLD_DECISION_MAX];

   int FindOld(int ticket,int old_count,int &old_ticket[])
   {
      for(int i = 0; i < old_count; i++)
         if(old_ticket[i] == ticket) return i;
      return -1;
   }

public:
   PendingTrailingDecisionObserver() { Reset(); }

   void Reset()
   {
      m_count = 0;
      for(int i = 0; i < ZGOLD_DECISION_MAX; i++)
      {
         m_ticket[i] = -1;
         m_reference_baseline[i] = 0.0;
         m_current_ref[i] = 0.0;
         m_reference_move[i] = 0.0;
         m_triggered[i] = false;
      }
   }

   void Evaluate(PendingState &p, PendingTrailingObserver &trail, double bid, double ask)
   {
      int old_count = m_count;
      int old_ticket[ZGOLD_DECISION_MAX];
      double old_baseline[ZGOLD_DECISION_MAX];

      for(int i = 0; i < ZGOLD_DECISION_MAX; i++)
      {
         old_ticket[i] = m_ticket[i];
         old_baseline[i] = m_reference_baseline[i];
      }

      m_count = p.Count();
      if(m_count > ZGOLD_DECISION_MAX)
         m_count = ZGOLD_DECISION_MAX;

      for(int j = 0; j < ZGOLD_DECISION_MAX; j++)
      {
         m_ticket[j] = -1;
         m_reference_baseline[j] = 0.0;
         m_current_ref[j] = 0.0;
         m_reference_move[j] = 0.0;
         m_triggered[j] = false;
      }

      for(int k = 0; k < m_count; k++)
      {
         int ticket = p.Ticket(k);
         int old_index = FindOld(ticket,old_count,old_ticket);
         double current_ref = (p.Type(k) == OP_BUYSTOP ? ask : bid);

         m_ticket[k] = ticket;
         m_current_ref[k] = current_ref;

         if(old_index < 0)
         {
            m_reference_baseline[k] = current_ref;
            continue;
         }

         m_reference_baseline[k] = old_baseline[old_index];
         m_reference_move[k] = MathAbs(current_ref - m_reference_baseline[k]);

         if(m_reference_move[k] >= 0.50 - Point * 0.1 &&
            trail.Ticket(k) == ticket &&
            trail.Valid(k) &&
            trail.DistanceClass(k) != "UNRESOLVED")
         {
            m_triggered[k] = true;
            // Re-arm from the new reference. This models the baseline that
            // would exist after the corresponding pending-price adjustment.
            m_reference_baseline[k] = current_ref;
         }
      }
   }

   int Count() const { return m_count; }
   int Ticket(int index) const { if(index < 0 || index >= m_count) return -1; return m_ticket[index]; }
   double Baseline(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_reference_baseline[index]; }
   double PreviousReference(int index) const { return Baseline(index); }
   double CurrentReference(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_current_ref[index]; }
   double ReferenceMove(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_reference_move[index]; }
   bool Triggered(int index) const { if(index < 0 || index >= m_count) return false; return m_triggered[index]; }

   int Decision(PendingTrailingObserver &trail) const
   {
      for(int i = 0; i < m_count; i++)
      {
         if(!m_triggered[i]) continue;
         if(trail.Ticket(i) != m_ticket[i]) continue;
         if(!trail.Valid(i)) continue;
         if(trail.DistanceClass(i) == "UNRESOLVED") continue;
         return ZGOLD_DECISION_TRAIL;
      }
      return ZGOLD_DECISION_HOLD;
   }

   int DecisionTicket(PendingTrailingObserver &trail) const
   {
      for(int i = 0; i < m_count; i++)
      {
         if(!m_triggered[i]) continue;
         if(trail.Ticket(i) != m_ticket[i]) continue;
         if(!trail.Valid(i)) continue;
         if(trail.DistanceClass(i) == "UNRESOLVED") continue;
         return m_ticket[i];
      }
      return -1;
   }

   string DecisionText(PendingTrailingObserver &trail) const
   {
      if(Decision(trail) == ZGOLD_DECISION_TRAIL) return "TRAIL_PENDING";
      return "HOLD";
   }

   string ActionText(PendingTrailingObserver &trail) const
   {
      if(Decision(trail) == ZGOLD_DECISION_TRAIL) return "MODIFY_CANDIDATE";
      return "NONE";
   }

   string ReasonText(PendingTrailingObserver &trail) const
   {
      int ticket = DecisionTicket(trail);
      if(ticket < 0) return "NO TRAILING TRIGGER";
      return "REFERENCE MOVE >= 0.50";
   }
};

#endif
