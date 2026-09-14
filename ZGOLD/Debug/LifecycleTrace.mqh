#ifndef __ZGOLD_LIFECYCLE_TRACE_MQH__
#define __ZGOLD_LIFECYCLE_TRACE_MQH__

class LifecycleTrace
{
private:
   string m_transition;
   string m_ticket;
   string m_previous;
   string m_current;
   string m_lots;
   string m_old_price;
   string m_new_price;

public:
   LifecycleTrace()
   {
      Reset();
   }

   void Reset()
   {
      m_transition = "NO CHANGE";
      m_ticket = "-";
      m_previous = "-";
      m_current = "-";
      m_lots = "0.00";
      m_old_price = "0.00";
      m_new_price = "0.00";
   }

   void Set(string transition, int ticket, string previous, string current,
            double lots, double old_price, double new_price)
   {
      m_transition = transition;
      m_ticket = IntegerToString(ticket);
      m_previous = previous;
      m_current = current;
      m_lots = DoubleToString(lots, 2);
      m_old_price = DoubleToString(old_price, Digits);
      m_new_price = DoubleToString(new_price, Digits);
   }

   string Transition() const { return m_transition; }
   string Ticket() const { return m_ticket; }
   string Previous() const { return m_previous; }
   string Current() const { return m_current; }
   string Lots() const { return m_lots; }
   string OldPrice() const { return m_old_price; }
   string NewPrice() const { return m_new_price; }
};

#endif
