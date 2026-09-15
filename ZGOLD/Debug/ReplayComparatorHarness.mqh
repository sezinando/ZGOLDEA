#ifndef __ZGOLD_REPLAY_COMPARATOR_HARNESS_MQH__
#define __ZGOLD_REPLAY_COMPARATOR_HARNESS_MQH__

#include "ReplayTraceRecord.mqh"
#include "BacktestComparatorObserver.mqh"

// Stage 96: replay comparator alignment and causal divergence gate.
// Comparison only. No trading API calls.
#define ZGOLD_DIV_NONE "NONE"
#define ZGOLD_DIV_D0 "D0_TEMPORAL_ALIGNMENT"
#define ZGOLD_DIV_D1 "D1_EVENT"
#define ZGOLD_DIV_D2 "D2_DECISION"
#define ZGOLD_DIV_D3 "D3_PRICE_OR_GEOMETRY"
#define ZGOLD_DIV_D4 "D4_LOT_OR_LIFECYCLE"
#define ZGOLD_DIV_D5 "D5_STATE_OR_EXPOSURE"

class ReplayComparatorHarness
{
private:
   bool m_enabled;
   int m_sequence;
   int m_time_tolerance_seconds;
   double m_price_tolerance;
   double m_lot_tolerance;
   string m_last_divergence;
   string m_first_divergence;
   string m_first_reference_time;
   string m_first_observed_time;
   ReplayTraceRecord m_reference;
   ReplayTraceRecord m_observed;
   BacktestComparatorObserver m_comparator;

public:
   ReplayComparatorHarness(){m_enabled=false;m_sequence=0;m_time_tolerance_seconds=1;m_price_tolerance=0.01;m_lot_tolerance=0.01;Reset();}
   void Enable(bool enabled){m_enabled=enabled;}
   bool Enabled() const{return m_enabled;}
   void Configure(int time_tolerance_seconds,double price_tolerance,double lot_tolerance){m_time_tolerance_seconds=MathMax(0,time_tolerance_seconds);m_price_tolerance=MathMax(0.0,price_tolerance);m_lot_tolerance=MathMax(0.0,lot_tolerance);}
   void Reset(){m_sequence=0;m_last_divergence=ZGOLD_DIV_NONE;m_first_divergence="";m_first_reference_time="";m_first_observed_time="";m_reference.Reset();m_observed.Reset();m_comparator.Reset();}
   void LoadReference(ReplayTraceRecord &record){m_reference=record;m_first_reference_time=record.Timestamp();}
   void LoadObserved(ReplayTraceRecord &record){m_observed=record;m_first_observed_time=record.Timestamp();}
   bool Ready() const{return(m_reference.Timestamp()!=""&&m_observed.Timestamp()!="");}
   bool TemporalAligned() const
   {
      datetime ref_time=StringToTime(m_reference.Timestamp());
      datetime obs_time=StringToTime(m_observed.Timestamp());
      if(ref_time<=0||obs_time<=0)return(m_reference.Timestamp()==m_observed.Timestamp());
      return(MathAbs((double)(ref_time-obs_time))<=m_time_tolerance_seconds);
   }
   string CompareCurrent()
   {
      if(!m_enabled||!Ready())return "UNRESOLVED";
      m_sequence++;m_last_divergence=ZGOLD_DIV_NONE;
      bool temporal_aligned=TemporalAligned();
      bool event_match=(m_reference.EventType()==m_observed.EventType());
      bool direction_match=(m_reference.Direction()==m_observed.Direction());
      bool order_type_match=(m_reference.OrderType()==m_observed.OrderType());
      bool decision_match=(m_reference.Reason()==m_observed.Reason());
      bool price_match=(MathAbs(m_reference.Price()-m_observed.Price())<=m_price_tolerance);
      bool reference_price_match=(MathAbs(m_reference.ReferencePrice()-m_observed.ReferencePrice())<=m_price_tolerance);
      bool distance_match=(MathAbs(m_reference.Distance()-m_observed.Distance())<=m_price_tolerance);
      bool lot_match=(MathAbs(m_reference.Lots()-m_observed.Lots())<=m_lot_tolerance);
      bool lifecycle_match=(m_reference.Lifecycle()==m_observed.Lifecycle());
      bool state_match=(m_reference.BuyCount()==m_observed.BuyCount()&&m_reference.SellCount()==m_observed.SellCount()&&MathAbs(m_reference.BuyLots()-m_observed.BuyLots())<=m_lot_tolerance&&MathAbs(m_reference.SellLots()-m_observed.SellLots())<=m_lot_tolerance);
      m_comparator.CompareEvent(event_match&&direction_match&&order_type_match,m_observed.Timestamp());
      m_comparator.CompareDecision(decision_match);
      m_comparator.ComparePrice(price_match&&reference_price_match&&distance_match);
      m_comparator.CompareLot(lot_match);
      m_comparator.CompareLifecycle(lifecycle_match);
      if(!temporal_aligned)m_last_divergence=ZGOLD_DIV_D0;
      else if(!(event_match&&direction_match&&order_type_match))m_last_divergence=ZGOLD_DIV_D1;
      else if(!decision_match)m_last_divergence=ZGOLD_DIV_D2;
      else if(!(price_match&&reference_price_match&&distance_match))m_last_divergence=ZGOLD_DIV_D3;
      else if(!lot_match||!lifecycle_match)m_last_divergence=ZGOLD_DIV_D4;
      else if(!state_match)m_last_divergence=ZGOLD_DIV_D5;
      if(m_last_divergence!=ZGOLD_DIV_NONE)RememberFirstDivergence();
      return m_last_divergence;
   }
   string LastDivergence() const{return m_last_divergence;}
   string FirstDivergence() const{return m_first_divergence;}
   string ReferenceTimestamp() const{return m_first_reference_time;}
   string ObservedTimestamp() const{return m_first_observed_time;}
   int Sequence() const{return m_sequence;}
   double PriceTolerance() const{return m_price_tolerance;}
   double LotTolerance() const{return m_lot_tolerance;}
   int TimeToleranceSeconds() const{return m_time_tolerance_seconds;}
   BacktestComparatorObserver &Comparator(){return m_comparator;}
private:
   void RememberFirstDivergence(){if(m_first_divergence=="")m_first_divergence=m_observed.Timestamp();}
};
#endif
