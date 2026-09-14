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
      if(type == OP_BUY)      return "BUY";
      if(type == OP_SELL)     return "SELL";
      if(type == OP_BUYSTOP)  return "BUY STOP";
      if(type == OP_SELLSTOP) return "SELL STOP";
      if(type == OP_BUYLIMIT) return "BUY LIMIT";
      if(type == OP_SELLLIMIT)return "SELL LIMIT";
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
      }
   }

   void Reconcile(int magic)
   {
      int cur_ticket[ZGOLD_LIFECYCLE_MAX_ORDERS];
      int cur_type[ZGOLD_LIFECYCLE_MAX_ORDERS];
      double cur_lots[ZGOLD_LIFECYCLE_MAX_ORDERS];
      double cur_price[ZGOLD_LIFECYCLE_MAX_ORDERS];
      int cur_count = 0;

      for(int init = 0; init < ZGOLD_LIFECYCLE_MAX_ORDERS; init++)
      {
         cur_ticket[init] = -1;
         cur_type[init] = -1;
         cur_lots[init] = 0.0;
         cur_price[init] = 0.0;
      }

      m_event = ZGOLD_LIFE_NONE;
      m_ticket = -1;
      m_type = -1;
      m_lots = 0.0;
      m_price = 0.0;
      m_event_text = "NO CHANGE";

      for(int i = OrdersTotal() - 1; i >= 0 && cur_count < ZGOLD_LIFECYCLE_MAX_ORDERS; i--)
      {
         if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic)
            continue;

         int ticket = OrderTicket();
         int type = OrderType();
         double lots = OrderLots();
         double price = OrderOpenPrice();

         cur_ticket[cur_count] = ticket;
         cur_type[cur_count] = type;
         cur_lots[cur_count] = lots;
         cur_price[cur_count] = price;
         cur_count++;

         int p = FindPrevious(ticket);

         if(p < 0)
         {
            if(!m_initialized)
               continue;

            SetEvent(ZGOLD_LIFE_CREATED, ticket, type, lots, price,
                     "CREATED #" + IntegerToString(ticket) + " " + TypeName(type));
            break;
         }

         if(m_prev_type[p] != type)
         {
            if(IsPendingType(m_prev_type[p]) && (type == OP_BUY || type == OP_SELL))
            {
               SetEvent(ZGOLD_LIFE_EXECUTED, ticket, type, lots, price,
                        "EXECUTED #" + IntegerToString(ticket) + " -> " + TypeName(type));
               break;
            }
         }

         if(m_prev_type[p] == type && IsPendingType(type))
         {
            if(MathAbs(m_prev_price[p] - price) > Point * 0.1 ||
               MathAbs(m_prev_lots[p] - lots) > 0.0000001)
            {
               SetEvent(ZGOLD_LIFE_MODIFIED, ticket, type, lots, price,
                        "MODIFIED #" + IntegerToString(ticket) + " " + TypeName(type));
               break;
            }
         }
      }

      if(m_event == ZGOLD_LIFE_NONE && m_initialized)
      {
         for(int p = 0; p < m_prev_count; p++)
         {
            bool found = false;
            for(int c = 0; c < cur_count; c++)
            {
               if(cur_ticket[c] == m_prev_ticket[p])
               {
                  found = true;
                  break;
               }
            }

            if(found)
               continue;

            int history_type = m_prev_type[p];
            double history_lots = m_prev_lots[p];
            double history_price = m_prev_price[p];

            if(OrderSelect(m_prev_ticket[p], SELECT_BY_TICKET, MODE_HISTORY))
            {
               history_type = OrderType();
               history_lots = OrderLots();
               history_price = OrderOpenPrice();
            }

            if(history_type == OP_BUY || history_type == OP_SELL)
            {
               SetEvent(ZGOLD_LIFE_CLOSED, m_prev_ticket[p], history_type, history_lots, history_price,
                        "CLOSED #" + IntegerToString(m_prev_ticket[p]) + " " + TypeName(history_type));
               break;
            }

            if(IsPendingType(history_type))
            {
               SetEvent(ZGOLD_LIFE_DELETED, m_prev_ticket[p], history_type,
                        history_lots, history_price,
                        "DELETED #" + IntegerToString(m_prev_ticket[p]));
               break;
            }
         }
      }

      if(!m_initialized)
      {
         SetEvent(ZGOLD_LIFE_SNAPSHOT, -1, -1, 0.0, 0.0, "INITIAL SNAPSHOT");
         m_initialized = true;
      }

      m_prev_count = cur_count;
      for(int k = 0; k < cur_count; k++)
      {
         m_prev_ticket[k] = cur_ticket[k];
         m_prev_type[k] = cur_type[k];
         m_prev_lots[k] = cur_lots[k];
         m_prev_price[k] = cur_price[k];
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
