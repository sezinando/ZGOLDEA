#ifndef __ZGOLD_LAYER_ENGINE_OBSERVER_MQH__
#define __ZGOLD_LAYER_ENGINE_OBSERVER_MQH__

#include "../State/ExposureState.mqh"
#include "../State/PendingState.mqh"

#define ZGOLD_LAYER_STATE_EMPTY     0
#define ZGOLD_LAYER_STATE_INITIAL   1
#define ZGOLD_LAYER_STATE_EXPANSION 2

class LayerEngineObserver
{
private:
   string m_buy_state;
   string m_sell_state;
   string m_buy_regime;
   string m_sell_regime;
   double m_buy_min;
   double m_buy_max;
   double m_sell_min;
   double m_sell_max;
   string m_buy_reference;
   string m_sell_reference;
   string m_buy_reason;
   string m_sell_reason;

   void ResetDirection(string &state,string &regime,double &min_price,double &max_price,string &reference,string &reason)
   {
      state="EMPTY";
      regime="UNRESOLVED";
      min_price=0.0;
      max_price=0.0;
      reference="UNRESOLVED";
      reason="NO MARKET POSITIONS";
   }

public:
   LayerEngineObserver() { Reset(); }

   void Reset()
   {
      m_buy_state="EMPTY";
      m_sell_state="EMPTY";
      m_buy_regime="UNRESOLVED";
      m_sell_regime="UNRESOLVED";
      m_buy_min=0.0;
      m_buy_max=0.0;
      m_sell_min=0.0;
      m_sell_max=0.0;
      m_buy_reference="UNRESOLVED";
      m_sell_reference="UNRESOLVED";
      m_buy_reason="NO MARKET POSITIONS";
      m_sell_reason="NO MARKET POSITIONS";
   }

   void Evaluate(ExposureState &e,PendingState &p)
   {
      Reset();

      // Current directional layer state is observable from active exposure.
      // The discriminator between the ~0.80 and ~3.40 expansion regimes is
      // intentionally left unresolved until it is proven from replay.
      if(e.BuyCount() > 0)
      {
         m_buy_state = "EXPANSION";
         m_buy_regime = "UNRESOLVED";
         m_buy_reason = "BUY EXPOSURE ACTIVE; REGIME NOT PROVEN";
      }
      else if(e.BuyCount() == 0)
      {
         m_buy_state = "INITIAL";
         m_buy_regime = "UNRESOLVED";
         m_buy_reason = "BUY DIRECTION RESET/EMPTY";
      }

      if(e.SellCount() > 0)
      {
         m_sell_state = "EXPANSION";
         m_sell_regime = "UNRESOLVED";
         m_sell_reason = "SELL EXPOSURE ACTIVE; REGIME NOT PROVEN";
      }
      else if(e.SellCount() == 0)
      {
         m_sell_state = "INITIAL";
         m_sell_regime = "UNRESOLVED";
         m_sell_reason = "SELL DIRECTION RESET/EMPTY";
      }

      // Extremes of current positions are proven structural observables.
      // Exact selection of the reference used for a new layer is unresolved.
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderSymbol()!=Symbol()) continue;
         int type=OrderType();
         if(type==OP_BUY)
         {
            double px=OrderOpenPrice();
            if(m_buy_min==0.0 || px<m_buy_min) m_buy_min=px;
            if(m_buy_max==0.0 || px>m_buy_max) m_buy_max=px;
         }
         else if(type==OP_SELL)
         {
            double px=OrderOpenPrice();
            if(m_sell_min==0.0 || px<m_sell_min) m_sell_min=px;
            if(m_sell_max==0.0 || px>m_sell_max) m_sell_max=px;
         }
      }

      if(e.BuyCount()>0)
      {
         m_buy_reference="STRUCTURAL EXTREMA AVAILABLE";
         m_buy_reason += "; REFERENCE SELECTION UNRESOLVED";
      }
      else
      {
         m_buy_reference="DIRECTIONAL RESET";
      }

      if(e.SellCount()>0)
      {
         m_sell_reference="STRUCTURAL EXTREMA AVAILABLE";
         m_sell_reason += "; REFERENCE SELECTION UNRESOLVED";
      }
      else
      {
         m_sell_reference="DIRECTIONAL RESET";
      }
   }

   string BuyState() const { return m_buy_state; }
   string SellState() const { return m_sell_state; }
   string BuyRegime() const { return m_buy_regime; }
   string SellRegime() const { return m_sell_regime; }
   double BuyMin() const { return m_buy_min; }
   double BuyMax() const { return m_buy_max; }
   double SellMin() const { return m_sell_min; }
   double SellMax() const { return m_sell_max; }
   string BuyReference() const { return m_buy_reference; }
   string SellReference() const { return m_sell_reference; }
   string BuyReason() const { return m_buy_reason; }
   string SellReason() const { return m_sell_reason; }
};

#endif
