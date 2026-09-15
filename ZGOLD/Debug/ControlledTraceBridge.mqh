#ifndef __ZGOLD_CONTROLLED_TRACE_BRIDGE_MQH__
#define __ZGOLD_CONTROLLED_TRACE_BRIDGE_MQH__

// Stage 89: observation-only bridge.
// This class intentionally contains no trading API calls.

class ControlledTraceBridge
{
private:
   bool   m_enabled;
   int    m_sequence;
   string m_last_event;

public:
   ControlledTraceBridge()
   {
      m_enabled=true;
      m_sequence=0;
      m_last_event="";
   }

   void SetEnabled(bool enabled)
   {
      m_enabled=enabled;
   }

   bool Enabled() const
   {
      return m_enabled;
   }

   void CaptureLifecycle(string event_name,int ticket,string reason)
   {
      if(!m_enabled) return;
      m_sequence++;
      m_last_event=StringFormat("%d|LIFECYCLE|%s|#%d|%s",m_sequence,event_name,ticket,reason);
      Print("[ZGOLD][TRACE] ",m_last_event);
   }

   void CaptureDecision(string decision,string action,string reason,int ticket)
   {
      if(!m_enabled) return;
      m_sequence++;
      m_last_event=StringFormat("%d|DECISION|%s|%s|#%d|%s",m_sequence,decision,action,ticket,reason);
      Print("[ZGOLD][TRACE] ",m_last_event);
   }

   void CaptureState(string state,string reason)
   {
      if(!m_enabled) return;
      m_sequence++;
      m_last_event=StringFormat("%d|STATE|%s|%s",m_sequence,state,reason);
      Print("[ZGOLD][TRACE] ",m_last_event);
   }

   int Sequence() const
   {
      return m_sequence;
   }

   string LastEvent() const
   {
      return m_last_event;
   }
};

#endif
