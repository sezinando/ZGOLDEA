#ifndef __ZGOLD_RECOVERY_CYCLE_OBSERVER_MQH__
#define __ZGOLD_RECOVERY_CYCLE_OBSERVER_MQH__

#define ZGOLD_RECOVERY_NONE         0
#define ZGOLD_RECOVERY_CLOSEBY      1
#define ZGOLD_RECOVERY_4051_END     2
#define ZGOLD_RECOVERY_CLEANUP      3
#define ZGOLD_RECOVERY_RESET_READY  4
#define ZGOLD_RECOVERY_REBUILD      5

class RecoveryCycleObserver
{
private:
   int    m_status;
   string m_reason;
   bool   m_global_requested;
   bool   m_has_buy;
   bool   m_has_sell;
   int    m_pending_count;
   bool   m_cleanup_required;
   bool   m_rebuild_ready;
   double m_rebuild_lot;

public:
   RecoveryCycleObserver(){Reset();}

   void Reset()
   {
      m_status=ZGOLD_RECOVERY_NONE;
      m_reason="NO GLOBAL CYCLE";
      m_global_requested=false;
      m_has_buy=false;
      m_has_sell=false;
      m_pending_count=0;
      m_cleanup_required=false;
      m_rebuild_ready=false;
      m_rebuild_lot=0.01;
   }

   void Evaluate(int magic,bool global_triggered)
   {
      Reset();
      m_global_requested=global_triggered;

      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         int type=OrderType();
         if(type==OP_BUY) m_has_buy=true;
         else if(type==OP_SELL) m_has_sell=true;
         else if(type==OP_BUYSTOP || type==OP_SELLSTOP || type==OP_BUYLIMIT || type==OP_SELLLIMIT)
            m_pending_count++;
      }

      if(!m_global_requested)
         return;

      if(m_has_buy && m_has_sell)
      {
         m_status=ZGOLD_RECOVERY_CLOSEBY;
         m_reason="GLOBAL EXIT -> CLOSEBY PAIRING";
         return;
      }

      if(!m_has_buy || !m_has_sell)
      {
         m_status=ZGOLD_RECOVERY_4051_END;
         m_reason="CLOSEBY END SIGNAL / 4051 OBSERVED";
      }

      if(m_pending_count>0)
      {
         m_cleanup_required=true;
         m_status=ZGOLD_RECOVERY_CLEANUP;
         m_reason="GLOBAL RESET -> DELETE PENDING STRUCTURE";
         return;
      }

      if(!m_has_buy && !m_has_sell && m_pending_count==0)
      {
         m_rebuild_ready=true;
         m_status=ZGOLD_RECOVERY_REBUILD;
         m_reason="RESET COMPLETE -> REBUILD BILATERAL .01/.01";
         m_rebuild_lot=0.01;
         return;
      }
   }

   int Status() const{return m_status;}
   string Reason() const{return m_reason;}
   bool GlobalRequested() const{return m_global_requested;}
   bool HasBuy() const{return m_has_buy;}
   bool HasSell() const{return m_has_sell;}
   int PendingCount() const{return m_pending_count;}
   bool CleanupRequired() const{return m_cleanup_required;}
   bool RebuildReady() const{return m_rebuild_ready;}
   double RebuildLot() const{return m_rebuild_lot;}
};

#endif
