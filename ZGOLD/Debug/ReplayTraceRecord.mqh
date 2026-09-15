#ifndef __ZGOLD_REPLAY_TRACE_RECORD_MQH__
#define __ZGOLD_REPLAY_TRACE_RECORD_MQH__

class ReplayTraceRecord
{
private:
   string m_timestamp;
   string m_event_type;
   int    m_ticket;
   int    m_direction;
   int    m_order_type;
   double m_lots;
   double m_price;
   double m_previous_price;
   double m_reference_price;
   string m_reference_type;
   double m_distance;
   string m_distance_family;
   int    m_buy_count;
   int    m_sell_count;
   double m_buy_lots;
   double m_sell_lots;
   double m_buy_profit;
   double m_sell_profit;
   double m_total_profit;
   double m_target;
   double m_result;
   int    m_winner_ticket;
   int    m_loss1_ticket;
   int    m_loss2_ticket;
   string m_lifecycle;
   string m_reason;

public:
   ReplayTraceRecord()
   {
      Reset();
   }

   void Reset()
   {
      m_timestamp="";
      m_event_type="NONE";
      m_ticket=-1;
      m_direction=-1;
      m_order_type=-1;
      m_lots=0.0;
      m_price=0.0;
      m_previous_price=0.0;
      m_reference_price=0.0;
      m_reference_type="UNRESOLVED";
      m_distance=0.0;
      m_distance_family="OTHER";
      m_buy_count=0;
      m_sell_count=0;
      m_buy_lots=0.0;
      m_sell_lots=0.0;
      m_buy_profit=0.0;
      m_sell_profit=0.0;
      m_total_profit=0.0;
      m_target=0.0;
      m_result=0.0;
      m_winner_ticket=-1;
      m_loss1_ticket=-1;
      m_loss2_ticket=-1;
      m_lifecycle="NONE";
      m_reason="";
   }

   void SetCore(string timestamp,string event_type,int ticket,int direction,int order_type,
                double lots,double price,double previous_price)
   {
      m_timestamp=timestamp;
      m_event_type=event_type;
      m_ticket=ticket;
      m_direction=direction;
      m_order_type=order_type;
      m_lots=lots;
      m_price=price;
      m_previous_price=previous_price;
   }

   void SetStructure(double reference_price,string reference_type,double distance,string distance_family)
   {
      m_reference_price=reference_price;
      m_reference_type=reference_type;
      m_distance=distance;
      m_distance_family=distance_family;
   }

   void SetExposure(int buy_count,int sell_count,double buy_lots,double sell_lots,
                    double buy_profit,double sell_profit,double total_profit)
   {
      m_buy_count=buy_count;
      m_sell_count=sell_count;
      m_buy_lots=buy_lots;
      m_sell_lots=sell_lots;
      m_buy_profit=buy_profit;
      m_sell_profit=sell_profit;
      m_total_profit=total_profit;
   }

   void SetExit(double target,double result,int winner_ticket,int loss1_ticket,int loss2_ticket)
   {
      m_target=target;
      m_result=result;
      m_winner_ticket=winner_ticket;
      m_loss1_ticket=loss1_ticket;
      m_loss2_ticket=loss2_ticket;
   }

   void SetLifecycle(string lifecycle,string reason)
   {
      m_lifecycle=lifecycle;
      m_reason=reason;
   }

   string Timestamp() const { return m_timestamp; }
   string EventType() const { return m_event_type; }
   int Ticket() const { return m_ticket; }
   int Direction() const { return m_direction; }
   int OrderType() const { return m_order_type; }
   double Lots() const { return m_lots; }
   double Price() const { return m_price; }
   double PreviousPrice() const { return m_previous_price; }
   double ReferencePrice() const { return m_reference_price; }
   string ReferenceType() const { return m_reference_type; }
   double Distance() const { return m_distance; }
   string DistanceFamily() const { return m_distance_family; }
   int BuyCount() const { return m_buy_count; }
   int SellCount() const { return m_sell_count; }
   double BuyLots() const { return m_buy_lots; }
   double SellLots() const { return m_sell_lots; }
   double BuyProfit() const { return m_buy_profit; }
   double SellProfit() const { return m_sell_profit; }
   double TotalProfit() const { return m_total_profit; }
   double Target() const { return m_target; }
   double Result() const { return m_result; }
   int WinnerTicket() const { return m_winner_ticket; }
   int Loss1Ticket() const { return m_loss1_ticket; }
   int Loss2Ticket() const { return m_loss2_ticket; }
   string Lifecycle() const { return m_lifecycle; }
   string Reason() const { return m_reason; }

   static string CsvHeader()
   {
      return "Timestamp;EventType;Ticket;Direction;OrderType;Lots;Price;PreviousPrice;ReferencePrice;ReferenceType;Distance;DistanceFamily;BuyCount;SellCount;BuyLots;SellLots;BuyProfit;SellProfit;TotalProfit;Target;Result;WinnerTicket;Loss1Ticket;Loss2Ticket;Lifecycle;Reason";
   }

   string CsvLine() const
   {
      return m_timestamp+";"+
             m_event_type+";"+
             IntegerToString(m_ticket)+";"+
             IntegerToString(m_direction)+";"+
             IntegerToString(m_order_type)+";"+
             DoubleToString(m_lots,2)+";"+
             DoubleToString(m_price,Digits)+";"+
             DoubleToString(m_previous_price,Digits)+";"+
             DoubleToString(m_reference_price,Digits)+";"+
             m_reference_type+";"+
             DoubleToString(m_distance,2)+";"+
             m_distance_family+";"+
             IntegerToString(m_buy_count)+";"+
             IntegerToString(m_sell_count)+";"+
             DoubleToString(m_buy_lots,2)+";"+
             DoubleToString(m_sell_lots,2)+";"+
             DoubleToString(m_buy_profit,2)+";"+
             DoubleToString(m_sell_profit,2)+";"+
             DoubleToString(m_total_profit,2)+";"+
             DoubleToString(m_target,2)+";"+
             DoubleToString(m_result,2)+";"+
             IntegerToString(m_winner_ticket)+";"+
             IntegerToString(m_loss1_ticket)+";"+
             IntegerToString(m_loss2_ticket)+";"+
             m_lifecycle+";"+
             m_reason;
   }
};

#endif
