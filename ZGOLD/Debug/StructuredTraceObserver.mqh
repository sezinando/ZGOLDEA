#ifndef __ZGOLD_STRUCTURED_TRACE_OBSERVER_MQH__
#define __ZGOLD_STRUCTURED_TRACE_OBSERVER_MQH__
#include "ReplayTraceRecord.mqh"

#define ZGOLD_TRACE_NONE        "NONE"
#define ZGOLD_TRACE_CREATE      "CREATE"
#define ZGOLD_TRACE_MODIFY      "MODIFY"
#define ZGOLD_TRACE_EXECUTE     "EXECUTE"
#define ZGOLD_TRACE_LAYER       "LAYER"
#define ZGOLD_TRACE_BASKET      "BASKET"
#define ZGOLD_TRACE_COMPRESSION "COMPRESSION"
#define ZGOLD_TRACE_CLOSEBY     "CLOSEBY"
#define ZGOLD_TRACE_CLOSE       "CLOSE"
#define ZGOLD_TRACE_RESET       "RESET"

class StructuredTraceObserver
{
private:
   ReplayTraceRecord m_record;
   bool m_enabled;

public:
   StructuredTraceObserver()
   {
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
      m_record.Reset();
   }

   ReplayTraceRecord &Record()
   {
      return m_record;
   }

   string Header() const
   {
      return ReplayTraceRecord::CsvHeader();
   }

   string Line() const
   {
      return m_record.CsvLine();
   }

   void Capture(string timestamp,string event_type,int ticket,int direction,int order_type,
                double lots,double price,double previous_price,
                double reference_price,string reference_type,double distance,string distance_family,
                int buy_count,int sell_count,double buy_lots,double sell_lots,
                double buy_profit,double sell_profit,double total_profit,
                double target,double result,int winner_ticket,int loss1_ticket,int loss2_ticket,
                string lifecycle,string reason)
   {
      if(!m_enabled)
         return;

      m_record.Reset();
      m_record.SetCore(timestamp,event_type,ticket,direction,order_type,lots,price,previous_price);
      m_record.SetStructure(reference_price,reference_type,distance,distance_family);
      m_record.SetExposure(buy_count,sell_count,buy_lots,sell_lots,buy_profit,sell_profit,total_profit);
      m_record.SetExit(target,result,winner_ticket,loss1_ticket,loss2_ticket);
      m_record.SetLifecycle(lifecycle,reason);
   }

   void PrintRecord() const
   {
      if(!m_enabled)
         return;

      Print("[ZGOLD][TRACE] ",m_record.CsvLine());
   }
};

#endif
