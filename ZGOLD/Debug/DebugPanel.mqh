#ifndef __ZGOLD_DEBUG_PANEL_MQH__
#define __ZGOLD_DEBUG_PANEL_MQH__

#define ZGOLD_PANEL_PREFIX "ZGOLD_DEBUG_"
#define ZGOLD_PANEL_PENDING_LINES 6

class DebugPanel
{
private:
   long   m_tick_count;
   string m_runtime_state;
   string m_last_event;
   string m_error;
   bool m_core, m_market, m_reconciler;
   int m_buy_count, m_sell_count;
   double m_buy_lots, m_sell_lots, m_buy_profit, m_sell_profit, m_total_profit;
   int m_pending_count;
   int m_pending_ticket[ZGOLD_PANEL_PENDING_LINES];
   int m_pending_type[ZGOLD_PANEL_PENDING_LINES];
   double m_pending_lots[ZGOLD_PANEL_PENDING_LINES];
   double m_pending_price[ZGOLD_PANEL_PENDING_LINES];

   void Label(string id, int x, int y, string text, int size=9)
   {
      string name = ZGOLD_PANEL_PREFIX + id;
      if(ObjectFind(0, name) < 0)
      {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
         ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
         ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      }
      ObjectSetString(0, name, OBJPROP_TEXT, text);
   }

   void Background()
   {
      string name = ZGOLD_PANEL_PREFIX + "BACKGROUND";
      if(ObjectFind(0, name) < 0)
      {
         ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
         ObjectSetInteger(0, name, OBJPROP_XSIZE, 520);
         ObjectSetInteger(0, name, OBJPROP_YSIZE, 520);
         ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBlack);
         ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrDimGray);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      }
   }

   string PendingTypeName(int type)
   {
      if(type == OP_BUYSTOP) return "BUY STOP";
      if(type == OP_SELLSTOP) return "SELL STOP";
      if(type == OP_BUYLIMIT) return "BUY LIMIT";
      if(type == OP_SELLLIMIT) return "SELL LIMIT";
      return "UNKNOWN";
   }

public:
   DebugPanel()
   {
      m_tick_count=0; m_runtime_state="RESET"; m_last_event="WAITING"; m_error="";
      m_core=false; m_market=false; m_reconciler=false;
      m_buy_count=0; m_sell_count=0; m_buy_lots=0; m_sell_lots=0;
      m_buy_profit=0; m_sell_profit=0; m_total_profit=0; m_pending_count=0;
      for(int i=0;i<ZGOLD_PANEL_PENDING_LINES;i++)
      {
         m_pending_ticket[i]=-1; m_pending_type[i]=0; m_pending_lots[i]=0; m_pending_price[i]=0;
      }
   }

   void Initialize() { Background(); Render(); }
   void IncrementTick() { m_tick_count++; }

   void SetModuleStatus(string module, bool status)
   {
      if(module=="CORE") m_core=status;
      else if(module=="MARKET STATE") m_market=status;
      else if(module=="STATE RECONCILER") m_reconciler=status;
   }
   void SetRuntimeState(string state) { m_runtime_state=state; }
   void SetLastEvent(string event_text) { m_last_event=event_text; }
   void SetError(string error_text) { m_error=error_text; }

   void SetMarket(double bid,double ask,double spread_points,datetime server_time)
   {
      Label("BID",25,110,"Bid       : "+DoubleToString(bid,Digits));
      Label("ASK",25,130,"Ask       : "+DoubleToString(ask,Digits));
      Label("SPREAD",25,150,"Spread    : "+DoubleToString(spread_points,1)+" points");
      Label("TIME",25,170,"Server    : "+TimeToString(server_time,TIME_DATE|TIME_SECONDS));
   }

   void SetExposure(int buy_count,double buy_lots,double buy_profit,int sell_count,double sell_lots,double sell_profit,double total_profit)
   {
      m_buy_count=buy_count; m_buy_lots=buy_lots; m_buy_profit=buy_profit;
      m_sell_count=sell_count; m_sell_lots=sell_lots; m_sell_profit=sell_profit; m_total_profit=total_profit;
   }

   void SetPending(PendingState &pending)
   {
      m_pending_count=pending.Count();
      for(int i=0;i<ZGOLD_PANEL_PENDING_LINES;i++)
      {
         m_pending_ticket[i]=-1; m_pending_type[i]=0; m_pending_lots[i]=0; m_pending_price[i]=0;
         if(i < m_pending_count)
         {
            m_pending_ticket[i]=pending.Ticket(i);
            m_pending_type[i]=pending.Type(i);
            m_pending_lots[i]=pending.Lots(i);
            m_pending_price[i]=pending.Price(i);
         }
      }
   }

   void Render()
   {
      Background();
      int x=25;
      Label("TITLE",x,20,"ZGOLD - DEBUG PANEL",11);
      Label("SYSTEM",x,55,"SYSTEM",9);
      Label("STATUS",x,75,"EA        : "+m_runtime_state);
      Label("SYMBOL",x,95,"SYMBOL    : "+Symbol());
      Label("MARKET",x,195,"MARKET",9);
      Label("RUNTIME",x,235,"RUNTIME",9);
      Label("TICK",x,255,"Tick      : "+IntegerToString((int)m_tick_count));
      Label("EXPOSURE",x,290,"EXPOSURE",9);
      Label("BUY",x,310,"BUY       : "+IntegerToString(m_buy_count)+" | "+DoubleToString(m_buy_lots,2)+" | "+DoubleToString(m_buy_profit,2));
      Label("SELL",x,330,"SELL      : "+IntegerToString(m_sell_count)+" | "+DoubleToString(m_sell_lots,2)+" | "+DoubleToString(m_sell_profit,2));
      Label("TOTAL",x,350,"TOTAL P/L : "+DoubleToString(m_total_profit,2));
      Label("PENDING",x,385,"PENDING : "+IntegerToString(m_pending_count),9);

      for(int i=0;i<ZGOLD_PANEL_PENDING_LINES;i++)
      {
         string id="P"+IntegerToString(i);
         string text="";
         if(i < m_pending_count)
            text=PendingTypeName(m_pending_type[i])+" #"+IntegerToString(m_pending_ticket[i])+" | "+DoubleToString(m_pending_lots[i],2)+" | "+DoubleToString(m_pending_price[i],Digits);
         else
            text="";
         Label(id,x,405+(i*20),text);
      }

      Label("MODULES",300,55,"MODULES",9);
      Label("CORE",300,75,"Core            ["+(m_core?"OK":"WAIT")+"]");
      Label("MARKET_MODULE",300,95,"MarketState     ["+(m_market?"OK":"WAIT")+"]");
      Label("RECONCILER",300,115,"Reconciler      ["+(m_reconciler?"OK":"WAIT")+"]");
      Label("EVENT",300,195,"LAST EVENT",9);
      Label("LAST_EVENT",300,215,"> "+m_last_event);
      if(m_error!="") Label("ERROR",300,235,"> ERROR: "+m_error);
   }

   void Destroy()
   {
      for(int i=ObjectsTotal()-1;i>=0;i--)
      {
         string name=ObjectName(i);
         if(StringFind(name,ZGOLD_PANEL_PREFIX,0)==0) ObjectDelete(0,name);
      }
   }
};

#endif
