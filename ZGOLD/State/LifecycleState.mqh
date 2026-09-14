#ifndef __ZGOLD_LIFECYCLE_STATE_MQH__
#define __ZGOLD_LIFECYCLE_STATE_MQH__

#define ZGOLD_LIFECYCLE_MAX_ORDERS 128
#define ZGOLD_LIFE_NONE       0
#define ZGOLD_LIFE_CREATED    1
#define ZGOLD_LIFE_MODIFIED   2
#define ZGOLD_LIFE_EXECUTED   3
#define ZGOLD_LIFE_CLOSED     4
#define ZGOLD_LIFE_DELETED    5
#define ZGOLD_LIFE_SNAPSHOT   6

class LifecycleState
{
private:
   int    m_prev_ticket[ZGOLD_LIFECYCLE_MAX_ORDERS];
   int    m_prev_type[ZGOLD_LIFECYCLE_MAX_ORDERS];
   double m_prev_lots[ZGOLD_LIFECYCLE_MAX_ORDERS];
   double m_prev_price[ZGOLD_LIFECYCLE_MAX_ORDERS];
   int    m_prev_count;
   bool   m_initialized;

   int    m_cur_ticket[ZGOLD_LIFECYCLE_MAX_ORDERS];
   int    m_cur_type[ZGOLD_LIFECYCLE_MAX_ORDERS];
   double m_cur_lots[ZGOLD_LIFECYCLE_MAX_ORDERS];
   double m_cur_price[ZGOLD_LIFECYCLE_MAX_ORDERS];
   int    m_cur_count;

   int    m_event;
   int    m_ticket;
   int    m_type;
   double m_lots;
   double m_price;
   string m_event_text;

   int FindPrevious(int ticket)
   {
      for(int i = 0; i < m_prev_count; i++)
      {
         if(m_prev_ticket[i] == ticket)
            return i;
      }
      return -1;
   }

   bool IsPendingType(int type)
   {
      return (type == OP_BUYSTOP || type == OP_SELLSTOP ||
              type == OP_BUYLIMIT || type == OP_SELLLIMIT);
   }

   string TypeName(int type)
   {
      if(type == OP_BUY)       return "BUY";
      if(type == OP_SELL)      return "SELL";
      if(type == OP_BUYSTOP)   return "BUY STOP";
      if(type == OP_SELLSTOP)  return "SELL STOP";
      if(type == OP_BUYLIMIT)  return "BUY LIMIT";
      if(type == OP_SELLLIMIT) return "SELL LIMIT";
      return "UNKNOWN";
   }

   void SetEvent(int event_code, int ticket, int type, double lots, double price, string text)
   {
      m_event = event_code;
      m_ticket = ticket;
      m_type = type;
      m_lots = lots;
      m_price = price;
      m_event_text = text;
   }

public:
   LifecycleState()
   {
      Reset();
   }

   void Reset()
   {
      m_prev_count = 0;
      m_cur_count = 0;
      m_initialized = false;
      m_event = ZGOLD_LIFE_NONE;
      m_ticket = -1;
      m_type = -1;
      m_lots = 0.0;
      m_price = 0.0;
      m_event_text = "WAITING";

      for(int i = 0; i < ZGOLD_LIFECYCLE_MAX_ORDERS; i++)
      {
         m_prev_ticket[i] = -1;
         m_prev_type[i] = -1;
         m_prev_lots[i] = 0.0;
         m_prev_price[i] = 0.0;
         m_cur_ticket[i] = -1;
         m_cur_type[i] = -1;
         m_cur_lots[i] = 0.0;
         m_cur_price[i] = 0.0;
      }
   }

   void Reconcile(int magic)
   {
      m_cur_count = 0;
      m_event = ZGOLD_LIFE_NONE;
      m_ticket = -1;
      m_type = -1;
      m_lots = 0.0;
      m_price = 0.0;
      m_event_text = "NO CHANGE";

      for(int i = OrdersTotal() - 1; i >= 0 && m_cur_count < ZGOLD_LIFECYCLE_MAX_ORDERS; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic)
            continue;

         m_cur_ticket[m_cur_count] = OrderTicket();
         m_cur_type[m_cur_count] = OrderType();
         m_cur_lots[m_cur_count] = OrderLots();
         m_cur_price[m_cur_count] = OrderOpenPrice();
         m_cur_count++;
      }

      if(!m_initialized)
      {
         SetEvent(ZGOLD_LIFE_SNAPSHOT, -1, -1, 0.0, 0.0, "INITIAL SNAPSHOT");
         m_initialized = true;
      }
      else
      {
         for(int c = 0; c < m_cur_count && m_event == ZGOLD_LIFE_NONE; c++)
         {
            int p = FindPrevious(m_cur_ticket[c]);

            if(p < 0)
            {
               SetEvent(ZGOLD_LIFE_CREATED, m_cur_ticket[c], m_cur_type[c],
                        m_cur_lots[c], m_cur_price[c],
                        "CREATED #" + IntegerToString(m_cur_ticket[c]) + " " + TypeName(m_cur_type[c]));
               break;
            }

            if(m_prev_type[p] != m_cur_type[c])
            {
               if(IsPendingType(m_prev_type[p]) &&
                  (m_cur_type[c] == OP_BUY || m_cur_type[c] == OP_SELL))
               {
                  SetEvent(ZGOLD_LIFE_EXECUTED, m_cur_ticket[c], m_cur_type[c],
                           m_cur_lots[c], m_cur_price[c],
                           "EXECUTED #" + IntegerToString(m_cur_ticket[c]) + " -> " + TypeName(m_cur_type[c]));
                  break;
               }
            }

            if(m_prev_type[p] == m_cur_type[c] && IsPendingType(m_cur_type[c]))
            {
               if(MathAbs(m_prev_price[p] - m_cur_price[c]) > Point * 0.1 ||
                  MathAbs(m_prev_lots[p] - m_cur_lots[c]) > 0.0000001)
               {
                  SetEvent(ZGOLD_LIFE_MODIFIED, m_cur_ticket[c], m_cur_type[c],
                           m_cur_lots[c], m_cur_price[c],
                           "MODIFIED #" + IntegerToString(m_cur_ticket[c]) + " " + TypeName(m_cur_type[c]));
                  break;
               }
            }
         }

         if(m_event == ZGOLD_LIFE_NONE)
         {
            for(int p2 = 0; p2 < m_prev_count; p2++)
            {
               bool found = false;

               for(int c2 = 0; c2 < m_cur_count; c2++)
               {
                  if(m_cur_ticket[c2] == m_prev_ticket[p2])
                  {
                     found = true;
                     break;
                  }
               }

               if(found)
                  continue;

               int history_type = m_prev_type[p2];
               double history_lots = m_prev_lots[p2];
               double history_price = m_prev_price[p2];

               if(OrderSelect(m_prev_ticket[p2], SELECT_BY_TICKET, MODE_HISTORY))
               {
                  history_type = OrderType();
                  history_lots = OrderLots();
                  history_price = OrderOpenPrice();
               }

               if(history_type == OP_BUY || history_type == OP_SELL)
               {
                  SetEvent(ZGOLD_LIFE_CLOSED, m_prev_ticket[p2], history_type,
                           history_lots, history_price,
                           "CLOSED #" + IntegerToString(m_prev_ticket[p2]) + " " + TypeName(history_type));
                  break;
               }

               if(IsPendingType(history_type))
               {
                  SetEvent(ZGOLD_LIFE_DELETED, m_prev_ticket[p2], history_type,
                           history_lots, history_price,
                           "DELETED #" + IntegerToString(m_prev_ticket[p2]));
                  break;
               }
            }
         }
      }

      m_prev_count = m_cur_count;
      for(int k = 0; k < m_cur_count; k++)
      {
         m_prev_ticket[k] = m_cur_ticket[k];
         m_prev_type[k] = m_cur_type[k];
         m_prev_lots[k] = m_cur_lots[k];
         m_prev_price[k] = m_cur_price[k];
      }
   }

   int Event() const { return m_event; }
   int Ticket() const { return m_ticket; }
   int Type() const { return m_type; }
   double Lots() const { return m_lots; }
   double Price() const { return m_price; }
   string EventText() const { return m_event_text; }
};

#endif
