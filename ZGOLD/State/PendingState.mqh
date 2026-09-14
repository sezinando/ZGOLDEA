#ifndef __ZGOLD_PENDING_STATE_MQH__
#define __ZGOLD_PENDING_STATE_MQH__

#define ZGOLD_PENDING_MAX 64
#define ZGOLD_PENDING_NONE      0
#define ZGOLD_PENDING_BUY_STOP  1
#define ZGOLD_PENDING_SELL_STOP 2
#define ZGOLD_PENDING_BUY_LIMIT 3
#define ZGOLD_PENDING_SELL_LIMIT 4

class PendingState
{
private:
   int    m_count;
   int    m_ticket[ZGOLD_PENDING_MAX];
   int    m_type[ZGOLD_PENDING_MAX];
   double m_lots[ZGOLD_PENDING_MAX];
   double m_price[ZGOLD_PENDING_MAX];

public:
   PendingState() { Reset(); }

   void Reset()
   {
      m_count = 0;
      for(int i = 0; i < ZGOLD_PENDING_MAX; i++)
      {
         m_ticket[i] = -1;
         m_type[i] = ZGOLD_PENDING_NONE;
         m_lots[i] = 0.0;
         m_price[i] = 0.0;
      }
   }

   bool Add(int ticket, int type, double lots, double price)
   {
      if(m_count >= ZGOLD_PENDING_MAX)
         return false;
      m_ticket[m_count] = ticket;
      m_type[m_count] = type;
      m_lots[m_count] = lots;
      m_price[m_count] = price;
      m_count++;
      return true;
   }

   int Count() const { return m_count; }
   int Ticket(int index) const { if(index < 0 || index >= m_count) return -1; return m_ticket[index]; }
   int Type(int index) const { if(index < 0 || index >= m_count) return ZGOLD_PENDING_NONE; return m_type[index]; }
   double Lots(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_lots[index]; }
   double Price(int index) const { if(index < 0 || index >= m_count) return 0.0; return m_price[index]; }

   int CountType(int type) const
   {
      int count = 0;
      for(int i = 0; i < m_count; i++)
         if(m_type[i] == type) count++;
      return count;
   }

   int BuyStopCount() const { return CountType(OP_BUYSTOP); }
   int SellStopCount() const { return CountType(OP_SELLSTOP); }
};

#endif
