#ifndef __ZGOLD_EXIT_DECISION_OBSERVER_MQH__
#define __ZGOLD_EXIT_DECISION_OBSERVER_MQH__

#include "ExitEngineObserver.mqh"
#include "CloseByObserver.mqh"

#define ZGOLD_EXIT_DEC_NONE        0
#define ZGOLD_EXIT_DEC_BASKET      1
#define ZGOLD_EXIT_DEC_COMPRESSION 2
#define ZGOLD_EXIT_DEC_GLOBAL      3
#define ZGOLD_EXIT_DEC_CLOSEBY     4
#define ZGOLD_EXIT_DEC_END         5

class ExitDecisionObserver
{
private:
   int m_decision;
   int m_direction;
   int m_ticket;
   int m_ticket2;
   string m_action;
   string m_reason;

public:
   ExitDecisionObserver(){Reset();}

   void Reset()
   {
      m_decision=ZGOLD_EXIT_DEC_NONE;
      m_direction=-1;
      m_ticket=-1;
      m_ticket2=-1;
      m_action="NONE";
      m_reason="NOT EVALUATED";
   }

   void Evaluate(ExitEngineObserver &exit,CloseByObserver &closeby,bool closeby_mode)
   {
      Reset();

      if(closeby_mode)
      {
         if(closeby.Status()==ZGOLD_CLOSEBY_RESIDUAL || closeby.Status()==ZGOLD_CLOSEBY_PAIR)
         {
            m_decision=ZGOLD_EXIT_DEC_CLOSEBY;
            m_direction=closeby.ResidualDirection();
            m_ticket=closeby.BuyTicket();
            m_ticket2=closeby.SellTicket();
            m_action="CLOSEBY_PAIR";
            m_reason=closeby.Reason();
            return;
         }
         if(closeby.Status()==ZGOLD_CLOSEBY_END)
         {
            m_decision=ZGOLD_EXIT_DEC_END;
            m_action="END_CLOSEBY";
            m_reason=closeby.Reason();
            return;
         }
      }

      if(exit.GlobalTriggered())
      {
         m_decision=ZGOLD_EXIT_DEC_GLOBAL;
         m_action="GLOBAL_EXIT";
         m_reason="TOTAL PROFIT >= 4";
         return;
      }

      if(exit.CompressionTriggered())
      {
         m_decision=ZGOLD_EXIT_DEC_COMPRESSION;
         m_direction=exit.CompressionDirection();
         m_ticket=exit.WinnerTicket();
         m_ticket2=exit.Loss1Ticket();
         m_action="COMPRESSION_CANDIDATE";
         m_reason="WINNER + 2 WORST | EXPOSURE GATE";
         return;
      }

      if(exit.BasketTriggered())
      {
         m_decision=ZGOLD_EXIT_DEC_BASKET;
         m_direction=exit.BasketDirection();
         m_action="BASKET_CLOSE_CANDIDATE";
         m_reason="DIRECTIONAL PROFIT >= COUNT * 20";
         return;
      }

      m_action="NONE";
      m_reason="NO EXIT CONDITION";
   }

   int Decision() const{return m_decision;}
   int Direction() const{return m_direction;}
   int Ticket() const{return m_ticket;}
   int Ticket2() const{return m_ticket2;}
   string Action() const{return m_action;}
   string Reason() const{return m_reason;}
};

#endif
