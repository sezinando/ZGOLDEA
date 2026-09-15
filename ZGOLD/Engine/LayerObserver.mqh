#ifndef __ZGOLD_LAYER_OBSERVER_MQH__
#define __ZGOLD_LAYER_OBSERVER_MQH__

#include "../State/ExposureState.mqh"
#include "../State/PendingState.mqh"

#define ZGOLD_LAYER_UNKNOWN 0
#define ZGOLD_LAYER_INITIAL  1
#define ZGOLD_LAYER_EXPANSION 2

class LayerObserver
{
private:
   string m_buy_state;
   string m_sell_state;
   string m_buy_confidence;
   string m_sell_confidence;
   double m_buy_min;
   double m_buy_max;
   double m_sell_min;
   double m_sell_max;
   double m_buy_reference;
   double m_sell_reference;
   string m_buy_reason;
   string m_sell_reason;

   void Range(ExposureState &e,bool buy,double &mn,double &mx,int &count)
   {
      mn=0.0; mx=0.0; count=(buy?e.BuyCount():e.SellCount());
   }

public:
   LayerObserver(){Reset();}

   void Reset()
   {
      m_buy_state="UNKNOWN"; m_sell_state="UNKNOWN";
      m_buy_confidence="UNRESOLVED"; m_sell_confidence="UNRESOLVED";
      m_buy_min=0.0; m_buy_max=0.0; m_sell_min=0.0; m_sell_max=0.0;
      m_buy_reference=0.0; m_sell_reference=0.0;
      m_buy_reason="NO BUY EXPOSURE"; m_sell_reason="NO SELL EXPOSURE";
   }

   void Evaluate(ExposureState &e,PendingState &p)
   {
      Reset();

      if(e.BuyCount()>0)
      {
         m_buy_state=(e.BuyCount()==1?"INITIAL":"EXPANSION");
         m_buy_confidence=(e.BuyCount()==1?"PROVEN":"STRONG");
         m_buy_reason=(e.BuyCount()==1?"SINGLE BUY POSITION":"MULTI-LAYER BUY EXPOSURE");
      }
      if(e.SellCount()>0)
      {
         m_sell_state=(e.SellCount()==1?"INITIAL":"EXPANSION");
         m_sell_confidence=(e.SellCount()==1?"PROVEN":"STRONG");
         m_sell_reason=(e.SellCount()==1?"SINGLE SELL POSITION":"MULTI-LAYER SELL EXPOSURE");
      }

      if(p.Count()>0)
      {
         for(int i=0;i<p.Count();i++)
         {
            if(p.Type(i)==OP_BUYSTOP && m_buy_reference==0.0) m_buy_reference=p.Price(i);
            if(p.Type(i)==OP_SELLSTOP && m_sell_reference==0.0) m_sell_reference=p.Price(i);
         }
      }
   }

   string BuyState() const {return m_buy_state;}
   string SellState() const {return m_sell_state;}
   string BuyConfidence() const {return m_buy_confidence;}
   string SellConfidence() const {return m_sell_confidence;}
   double BuyMin() const {return m_buy_min;}
   double BuyMax() const {return m_buy_max;}
   double SellMin() const {return m_sell_min;}
   double SellMax() const {return m_sell_max;}
   double BuyReference() const {return m_buy_reference;}
   double SellReference() const {return m_sell_reference;}
   string BuyReason() const {return m_buy_reason;}
   string SellReason() const {return m_sell_reason;}
};

#endif
