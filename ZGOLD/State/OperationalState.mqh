#ifndef __ZGOLD_OPERATIONAL_STATE_MQH__
#define __ZGOLD_OPERATIONAL_STATE_MQH__

#include "ExposureState.mqh"
#include "PendingState.mqh"

class OperationalState
{
private:
   string m_state;
   string m_reason;

public:
   OperationalState() { Reset(); }

   void Reset()
   {
      m_state = "RESET";
      m_reason = "NO STATE";
   }

   void Evaluate(ExposureState &e, PendingState &p)
   {
      if(e.BuyCount() == 0 && e.SellCount() == 0 && p.Count() == 0)
      {
         m_state = "EMPTY";
         m_reason = "NO EXPOSURE / NO PENDING";
         return;
      }

      if(e.BuyCount() == 0 && e.SellCount() == 0 && p.Count() > 0)
      {
         m_state = "BILATERAL_PENDING";
         m_reason = "PENDING INVENTORY ACTIVE";
         return;
      }

      if((e.BuyCount() > 0 || e.SellCount() > 0) && p.Count() > 0)
      {
         m_state = "EXPOSURE + PENDING";
         m_reason = "MARKET EXPOSURE AND PENDING COEXIST";
         return;
      }

      if(e.BuyCount() > 0 || e.SellCount() > 0)
      {
         m_state = "POSITION_EXPOSURE";
         m_reason = "MARKET POSITIONS ACTIVE";
         return;
      }

      m_state = "UNRESOLVED";
      m_reason = "STATE COMBINATION NOT CLASSIFIED";
   }

   string State() const { return m_state; }
   string Reason() const { return m_reason; }
};

#endif
