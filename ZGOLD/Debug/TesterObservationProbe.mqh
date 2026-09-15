#ifndef __ZGOLD_TESTER_OBSERVATION_PROBE_MQH__
#define __ZGOLD_TESTER_OBSERVATION_PROBE_MQH__

// Stage 94: Strategy Tester observation probe.
// Observation only. No trading API calls and no state mutation.

class TesterObservationProbe
{
private:
   bool   m_enabled;
   int    m_ticks;
   string m_first_time;
   string m_last_time;
   double m_first_bid;
   double m_first_ask;
   double m_last_bid;
   double m_last_ask;
   string m_last_lifecycle;
   string m_last_decision;
   string m_last_state;

public:
   TesterObservationProbe()
   {
      Reset();
      m_enabled=false;
   }

   void Enable(bool enabled)
   {
      m_enabled=enabled;
   }

   bool Enabled() const
   {
      return m_enabled;
   }

   void Reset()
   {
      m_ticks=0;
      m_first_time="";
      m_last_time="";
      m_first_bid=0.0;
      m_first_ask=0.0;
      m_last_bid=0.0;
      m_last_ask=0.0;
      m_last_lifecycle="NONE";
      m_last_decision="NONE";
      m_last_state="NONE";
   }

   void ObserveMarket(string timestamp,double bid,double ask)
   {
      if(!m_enabled)
         return;

      if(m_ticks==0)
      {
         m_first_time=timestamp;
         m_first_bid=bid;
         m_first_ask=ask;
      }

      m_ticks++;
      m_last_time=timestamp;
      m_last_bid=bid;
      m_last_ask=ask;
   }

   void ObserveLifecycle(string lifecycle)
   {
      if(!m_enabled) return;
      m_last_lifecycle=lifecycle;
   }

   void ObserveDecision(string decision)
   {
      if(!m_enabled) return;
      m_last_decision=decision;
   }

   void ObserveState(string state)
   {
      if(!m_enabled) return;
      m_last_state=state;
   }

   void PrintSnapshot()
   {
      if(!m_enabled)
         return;

      Print("[ZGOLD][STAGE94] TICKS=",m_ticks,
            " FIRST=",m_first_time,
            " LAST=",m_last_time,
            " BID=",DoubleToString(m_last_bid,Digits),
            " ASK=",DoubleToString(m_last_ask,Digits),
            " LIFECYCLE=",m_last_lifecycle,
            " DECISION=",m_last_decision,
            " STATE=",m_last_state);
   }

   int Ticks() const { return m_ticks; }
   string FirstTime() const { return m_first_time; }
   string LastTime() const { return m_last_time; }
   double FirstBid() const { return m_first_bid; }
   double FirstAsk() const { return m_first_ask; }
   double LastBid() const { return m_last_bid; }
   double LastAsk() const { return m_last_ask; }
   string LastLifecycle() const { return m_last_lifecycle; }
   string LastDecision() const { return m_last_decision; }
   string LastState() const { return m_last_state; }
};

#endif
