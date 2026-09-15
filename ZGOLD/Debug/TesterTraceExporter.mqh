#ifndef __ZGOLD_TESTER_TRACE_EXPORTER_MQH__
#define __ZGOLD_TESTER_TRACE_EXPORTER_MQH__

#include "ReplayTraceRecord.mqh"

// Stage 95: machine-readable Strategy Tester trace exporter.
// Observation/export only. This class never submits trading requests.

class TesterTraceExporter
{
private:
   bool m_enabled;
   long m_sequence;

public:
   TesterTraceExporter(){m_enabled=true;m_sequence=0;}

   void Enable(bool enabled){m_enabled=enabled;}
   bool Enabled() const{return m_enabled;}
   void Reset(){m_sequence=0;}

   void Emit(ReplayTraceRecord &r)
   {
      if(!m_enabled) return;
      m_sequence++;
      Print("[ZGOLD][TRACE95]",
            ";SEQ=",m_sequence,
            ";TS=",r.Timestamp(),
            ";EVENT=",r.EventType(),
            ";TICKET=",r.Ticket(),
            ";DIR=",r.Direction(),
            ";TYPE=",r.OrderType(),
            ";LOTS=",DoubleToString(r.Lots(),2),
            ";PRICE=",DoubleToString(r.Price(),Digits),
            ";PREV=",DoubleToString(r.PreviousPrice(),Digits),
            ";REF=",DoubleToString(r.ReferencePrice(),Digits),
            ";REFTYPE=",r.ReferenceType(),
            ";DIST=",DoubleToString(r.Distance(),2),
            ";DISTFAMILY=",r.DistanceFamily(),
            ";BC=",r.BuyCount(),
            ";SC=",r.SellCount(),
            ";BL=",DoubleToString(r.BuyLots(),2),
            ";SL=",DoubleToString(r.SellLots(),2),
            ";BP=",DoubleToString(r.BuyProfit(),2),
            ";SP=",DoubleToString(r.SellProfit(),2),
            ";TP=",DoubleToString(r.TotalProfit(),2),
            ";TARGET=",DoubleToString(r.Target(),2),
            ";RESULT=",DoubleToString(r.Result(),2),
            ";WINNER=",r.WinnerTicket(),
            ";LOSS1=",r.Loss1Ticket(),
            ";LOSS2=",r.Loss2Ticket(),
            ";LIFECYCLE=",r.Lifecycle(),
            ";REASON=",r.Reason());
   }

   long Sequence() const{return m_sequence;}
};

#endif
