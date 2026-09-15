#ifndef __ZGOLD_BACKTEST_COMPARATOR_OBSERVER_MQH__
#define __ZGOLD_BACKTEST_COMPARATOR_OBSERVER_MQH__

// Stage 90: comparator provisioning only.
// No trading, no file mutation, no order execution.

#define ZGOLD_CMP_UNRESOLVED "UNRESOLVED"
#define ZGOLD_CMP_MATCH       "MATCH"
#define ZGOLD_CMP_DIVERGENCE  "DIVERGENCE"

class BacktestComparatorObserver
{
private:
   string m_status;
   string m_first_divergence;
   int    m_event_matches;
   int    m_event_compared;
   int    m_decision_matches;
   int    m_decision_compared;
   int    m_price_matches;
   int    m_price_compared;
   int    m_lot_matches;
   int    m_lot_compared;
   int    m_lifecycle_matches;
   int    m_lifecycle_compared;

public:
   BacktestComparatorObserver()
   {
      Reset();
   }

   void Reset()
   {
      m_status=ZGOLD_CMP_UNRESOLVED;
      m_first_divergence="";
      m_event_matches=0;
      m_event_compared=0;
      m_decision_matches=0;
      m_decision_compared=0;
      m_price_matches=0;
      m_price_compared=0;
      m_lot_matches=0;
      m_lot_compared=0;
      m_lifecycle_matches=0;
      m_lifecycle_compared=0;
   }

   void CompareEvent(bool match,string timestamp)
   {
      m_event_compared++;
      if(match)
      {
         m_event_matches++;
         return;
      }
      if(m_first_divergence=="")
         m_first_divergence=timestamp;
      m_status=ZGOLD_CMP_DIVERGENCE;
   }

   void CompareDecision(bool match)
   {
      m_decision_compared++;
      if(match) m_decision_matches++;
   }

   void ComparePrice(bool match)
   {
      m_price_compared++;
      if(match) m_price_matches++;
   }

   void CompareLot(bool match)
   {
      m_lot_compared++;
      if(match) m_lot_matches++;
   }

   void CompareLifecycle(bool match)
   {
      m_lifecycle_compared++;
      if(match) m_lifecycle_matches++;
   }

   void Finalize()
   {
      if(m_event_compared>0 && m_event_matches==m_event_compared)
         m_status=ZGOLD_CMP_MATCH;
      else if(m_event_compared==0)
         m_status=ZGOLD_CMP_UNRESOLVED;
      else
         m_status=ZGOLD_CMP_DIVERGENCE;
   }

   string Status() const { return m_status; }
   string FirstDivergence() const { return m_first_divergence; }
   int EventMatches() const { return m_event_matches; }
   int EventCompared() const { return m_event_compared; }
   int DecisionMatches() const { return m_decision_matches; }
   int DecisionCompared() const { return m_decision_compared; }
   int PriceMatches() const { return m_price_matches; }
   int PriceCompared() const { return m_price_compared; }
   int LotMatches() const { return m_lot_matches; }
   int LotCompared() const { return m_lot_compared; }
   int LifecycleMatches() const { return m_lifecycle_matches; }
   int LifecycleCompared() const { return m_lifecycle_compared; }
};

#endif
