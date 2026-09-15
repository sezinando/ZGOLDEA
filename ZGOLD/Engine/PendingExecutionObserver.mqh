#ifndef __ZGOLD_PENDING_EXECUTION_OBSERVER_MQH__
#define __ZGOLD_PENDING_EXECUTION_OBSERVER_MQH__

#define ZGOLD_EXEC_NONE      0
#define ZGOLD_EXEC_EXECUTED  1
#define ZGOLD_EXEC_HOLD      2

class PendingExecutionObserver
{
private:
   int    m_status;
   int    m_ticket;
   int    m_type;
   double m_lots;
   double m_price;
   string m_reason;

public:
   PendingExecutionObserver(){Reset();}

   void Reset()
   {
      m_status=ZGOLD_EXEC_NONE;
      m_ticket=-1;
      m_type=-1;
      m_lots=0.0;
      m_price=0.0;
      m_reason="NO EXECUTION EVENT";
   }

   void Evaluate(int lifecycle_event,int ticket,int type,double lots,double price)
   {
      Reset();
      if(lifecycle_event==ZGOLD_LIFE_EXECUTED)
      {
         m_status=ZGOLD_EXEC_EXECUTED;
         m_ticket=ticket;
         m_type=type;
         m_lots=lots;
         m_price=price;
         m_reason="PENDING -> MARKET EXECUTION";
      }
      else
      {
         m_status=ZGOLD_EXEC_HOLD;
         m_reason="NO EXECUTION TRANSITION";
      }
   }

   int Status() const{return m_status;}
   int Ticket() const{return m_ticket;}
   int Type() const{return m_type;}
   double Lots() const{return m_lots;}
   double Price() const{return m_price;}
   string Reason() const{return m_reason;}
};

#endif
