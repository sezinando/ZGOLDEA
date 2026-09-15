#ifndef __ZGOLD_LAYER_CREATION_OBSERVER_MQH__
#define __ZGOLD_LAYER_CREATION_OBSERVER_MQH__

#include "../State/ExposureState.mqh"
#include "../State/PendingState.mqh"

#define ZGOLD_LAYER_CREATE_NONE       0
#define ZGOLD_LAYER_CREATE_INITIAL    1
#define ZGOLD_LAYER_CREATE_EXPANSION  2
#define ZGOLD_LAYER_CREATE_UNRESOLVED 3

class LayerCreationObserver
{
private:
   int    m_status;
   int    m_direction;
   int    m_source_ticket;
   double m_candidate_price;
   double m_candidate_lots;
   string m_reference;
   string m_reason;

public:
   LayerCreationObserver(){Reset();}

   void Reset()
   {
      m_status=ZGOLD_LAYER_CREATE_NONE;
      m_direction=-1;
      m_source_ticket=-1;
      m_candidate_price=0.0;
      m_candidate_lots=0.0;
      m_reference="UNRESOLVED";
      m_reason="NO LAYER CANDIDATE";
   }

   void Evaluate(ExposureState &e,PendingState &p)
   {
      Reset();

      // Candidate formation is observational. The exact Zeus reference
      // resolver remains unresolved, so a pending order is used only as the
      // observable source candidate and never as proof of the creation rule.
      if(p.Count()<=0)
      {
         m_reason="NO PENDING CANDIDATE";
         return;
      }

      int best=-1;
      for(int i=0;i<p.Count();i++)
      {
         int type=p.Type(i);
         if(type!=OP_BUYSTOP && type!=OP_SELLSTOP) continue;
         if(best<0 || p.Ticket(i)>p.Ticket(best)) best=i;
      }

      if(best<0)
      {
         m_reason="NO BUY/SELL STOP CANDIDATE";
         return;
      }

      m_source_ticket=p.Ticket(best);
      m_candidate_price=p.Price(best);
      m_candidate_lots=p.Lots(best);
      m_direction=(p.Type(best)==OP_BUYSTOP ? OP_BUY : OP_SELL);

      if((m_direction==OP_BUY && e.BuyCount()==0) ||
         (m_direction==OP_SELL && e.SellCount()==0))
      {
         m_status=ZGOLD_LAYER_CREATE_INITIAL;
         m_reference="FIRSTSTEP / INITIAL STRUCTURE";
         m_reason="INITIAL DIRECTIONAL CANDIDATE";
      }
      else if((m_direction==OP_BUY && e.BuyCount()>0) ||
              (m_direction==OP_SELL && e.SellCount()>0))
      {
         m_status=ZGOLD_LAYER_CREATE_EXPANSION;
         m_reference="STRUCTURAL REFERENCE UNRESOLVED";
         m_reason="EXPANSION CANDIDATE; EXACT REFERENCE UNRESOLVED";
      }
      else
      {
         m_status=ZGOLD_LAYER_CREATE_UNRESOLVED;
         m_reason="DIRECTIONAL STATE CONFLICT";
      }
   }

   int Status() const{return m_status;}
   int Direction() const{return m_direction;}
   int SourceTicket() const{return m_source_ticket;}
   double CandidatePrice() const{return m_candidate_price;}
   double CandidateLots() const{return m_candidate_lots;}
   string Reference() const{return m_reference;}
   string Reason() const{return m_reason;}
};

#endif
