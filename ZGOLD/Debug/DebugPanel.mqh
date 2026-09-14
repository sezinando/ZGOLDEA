#ifndef __ZGOLD_DEBUG_PANEL_MQH__
#define __ZGOLD_DEBUG_PANEL_MQH__

#define ZGOLD_PANEL_PREFIX "ZGOLD_DEBUG_"

class DebugPanel
{
private:
   long   m_tick_count;
   string m_runtime_state;
   string m_last_event;
   string m_error;

   bool m_core;
   bool m_market;
   bool m_reconciler;

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
         ObjectSetInteger(0, name, OBJPROP_XSIZE, 420);
         ObjectSetInteger(0, name, OBJPROP_YSIZE, 300);
         ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBlack);
         ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrDimGray);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      }
   }

public:
   DebugPanel()
   {
      m_tick_count = 0;
      m_runtime_state = "RESET";
      m_last_event = "WAITING";
      m_error = "";
      m_core = false;
      m_market = false;
      m_reconciler = false;
   }

   void Initialize()
   {
      Background();
      Render();
   }

   void IncrementTick()
   {
      m_tick_count++;
   }

   void SetModuleStatus(string module, bool status)
   {
      if(module == "CORE")
         m_core = status;
      else if(module == "MARKET STATE")
         m_market = status;
      else if(module == "STATE RECONCILER")
         m_reconciler = status;
   }

   void SetRuntimeState(string state)
   {
      m_runtime_state = state;
   }

   void SetLastEvent(string event_text)
   {
      m_last_event = event_text;
   }

   void SetError(string error_text)
   {
      m_error = error_text;
   }

   void SetMarket(double bid, double ask, double spread, datetime server_time)
   {
      string bid_text = DoubleToString(bid, Digits);
      string ask_text = DoubleToString(ask, Digits);
      string spread_text = DoubleToString(spread, Digits);

      Label("BID", 25, 110, "Bid       : " + bid_text);
      Label("ASK", 25, 130, "Ask       : " + ask_text);
      Label("SPREAD", 25, 150, "Spread    : " + spread_text);
      Label("TIME", 25, 190, "Server    : " + TimeToString(server_time, TIME_DATE|TIME_SECONDS));
   }

   void Render()
   {
      Background();

      int x = 25;
      Label("TITLE", x, 20, "ZGOLD - DEBUG PANEL", 11);

      Label("SYSTEM", x, 55, "SYSTEM", 9);
      Label("STATUS", x, 75, "EA        : " + m_runtime_state);
      Label("SYMBOL", x, 95, "SYMBOL    : " + Symbol());

      Label("MARKET", x, 175, "MARKET", 9);

      Label("RUNTIME", x, 215, "RUNTIME", 9);
      Label("TICK", x, 235, "Tick      : " + LongToString(m_tick_count));

      Label("MODULES", x, 270, "MODULES", 9);
      Label("CORE", x, 290, "Core              [" + (m_core ? "OK" : "WAIT") + "]");
      Label("MARKET_MODULE", x, 310, "MarketState       [" + (m_market ? "OK" : "WAIT") + "]");
      Label("RECONCILER", x, 330, "StateReconciler   [" + (m_reconciler ? "OK" : "WAIT") + "]");

      Label("EVENT", 225, 270, "LAST EVENT", 9);
      Label("LAST_EVENT", 225, 290, "> " + m_last_event);

      if(m_error != "")
         Label("ERROR", 225, 310, "> ERROR: " + m_error);
   }

   void Destroy()
   {
      for(int i = ObjectsTotal() - 1; i >= 0; i--)
      {
         string name = ObjectName(i);
         if(StringFind(name, ZGOLD_PANEL_PREFIX, 0) == 0)
            ObjectDelete(0, name);
      }
   }
};

#endif
