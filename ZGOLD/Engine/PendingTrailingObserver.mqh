#ifndef __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__
#define __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__

#include "../State/PendingState.mqh"
#include "../Config/ZGoldParams.mqh"

#define ZGOLD_TRAIL_NONE 0
#define ZGOLD_TRAIL_BUY  1
#define ZGOLD_TRAIL_SELL 2
#define ZGOLD_TRAIL_MAX  6

// Canonical distance-family identifiers. Numeric distances are resolved from
// ZGoldParams; formatting must never be part of the decision contract.
#define ZGOLD_TRAIL_FAMILY_FIRSTSTEP   "FIRSTSTEP"
#define ZGOLD_TRAIL_FAMILY_MINDISTANCE "MINDISTANCE"

class PendingTrailingObserver
{
private:
   int    m_count;
   int    m_ticket[ZGOLD_TRAIL_MAX];
   int    m_type[ZGOLD_TRAIL_MAX];
   double m_oop[ZGOLD_TRAIL_MAX];
   double m_market_ref[ZGOLD_TRAIL_MAX];
   double m_candidate[ZGOLD_TRAIL_MAX];
   double m_delta[ZGOLD_TRAIL_MAX];
   string m_distance_class[ZGOLD_TRAIL_MAX];
   bool   m_valid[ZGOLD_TRAIL_MAX];
   string m_reason[ZGOLD_TRAIL_MAX];

   string TypeName(int type) const
   {
      if(type==OP_BUYSTOP) return "BUY STOP";
      if(type==OP_SELLSTOP) return "SELL STOP";
      return "UNKNOWN";
   }

   string InferDistanceFamily(double delta) const
   {
      double first_step=ZGoldParams::FirstStep();
      double min_distance=ZGoldParams::MinDistance();
      double tolerance=Point*2.0;

      if(MathAbs(delta-first_step)<=tolerance) return ZGOLD_TRAIL_FAMILY_FIRSTSTEP;
      if(MathAbs(delta-min_distance)<=tolerance) return ZGOLD_TRAIL_FAMILY_MINDISTANCE;
      return "UNRESOLVED";
   }

   void EvaluateOne(int index,int ticket,int type,double oop,double bid,double ask,string prior_family)
   {
      m_ticket[index]=ticket;
      m_type[index]=type;
      m_oop[index]=oop;
      m_market_ref[index]=(type==OP_BUYSTOP?ask:bid);
      m_candidate[index]=m_market_ref[index];
      m_delta[index]=0.0;
      m_distance_class[index]=prior_family;
      m_valid[index]=false;
      m_reason[index]="UNRESOLVED TYPE";

      if(type==OP_BUYSTOP)
      {
         m_delta[index]=oop-ask;
         m_valid[index]=(m_delta[index]>=0.0);
         m_reason[index]="BUY STOP reference = ASK";
      }
      else if(type==OP_SELLSTOP)
      {
         m_delta[index]=bid-oop;
         m_valid[index]=(m_delta[index]>=0.0);
         m_reason[index]="SELL STOP reference = BID";
      }
      else
      {
         m_valid[index]=false;
         m_distance_class[index]="UNRESOLVED";
         m_reason[index]="UNRESOLVED TYPE";
         return;
      }

      if(m_distance_class[index]=="UNRESOLVED")
         m_distance_class[index]=InferDistanceFamily(m_delta[index]);

      if(m_distance_class[index]!= "UNRESOLVED")
         m_reason[index]=m_reason[index]+" | FAMILY="+m_distance_class[index];
      else
         m_reason[index]=m_reason[index]+" | FAMILY UNRESOLVED";
   }

public:
   PendingTrailingObserver(){Reset();}

   void Reset()
   {
      m_count=0;
      for(int i=0;i<ZGOLD_TRAIL_MAX;i++)
      {
         m_ticket[i]=-1;
         m_type[i]=-1;
         m_oop[i]=0.0;
         m_market_ref[i]=0.0;
         m_candidate[i]=0.0;
         m_delta[i]=0.0;
         m_distance_class[i]="UNRESOLVED";
         m_valid[i]=false;
         m_reason[i]="NO PENDING";
      }
   }

   void EvaluateAll(PendingState &p,double bid,double ask)
   {
      int old_count=m_count;
      int old_ticket[ZGOLD_TRAIL_MAX];
      string old_family[ZGOLD_TRAIL_MAX];

      for(int i=0;i<ZGOLD_TRAIL_MAX;i++)
      {
         old_ticket[i]=m_ticket[i];
         old_family[i]=m_distance_class[i];
      }

      int total=p.Count();
      if(total>ZGOLD_TRAIL_MAX) total=ZGOLD_TRAIL_MAX;

      m_count=total;
      for(int i=0;i<ZGOLD_TRAIL_MAX;i++)
      {
         m_ticket[i]=-1;
         m_type[i]=-1;
         m_oop[i]=0.0;
         m_market_ref[i]=0.0;
         m_candidate[i]=0.0;
         m_delta[i]=0.0;
         m_distance_class[i]="UNRESOLVED";
         m_valid[i]=false;
         m_reason[i]="NO PENDING";
      }

      for(int i=0;i<total;i++)
      {
         int ticket=p.Ticket(i);
         string family="UNRESOLVED";
         for(int j=0;j<old_count;j++)
            if(old_ticket[j]==ticket)
            {
               family=old_family[j];
               break;
            }

         EvaluateOne(i,ticket,p.Type(i),p.Price(i),bid,ask,family);
      }
   }

   int Count() const{return m_count;}
   int Ticket(int index) const{if(index<0||index>=m_count)return -1;return m_ticket[index];}
   int Type(int index) const{if(index<0||index>=m_count)return -1;return m_type[index];}
   double OOP(int index) const{if(index<0||index>=m_count)return 0.0;return m_oop[index];}
   double MarketReference(int index) const{if(index<0||index>=m_count)return 0.0;return m_market_ref[index];}
   double Candidate(int index) const{if(index<0||index>=m_count)return 0.0;return m_candidate[index];}
   double Delta(int index) const{if(index<0||index>=m_count)return 0.0;return m_delta[index];}
   string DistanceClass(int index) const{if(index<0||index>=m_count)return "-";return m_distance_class[index];}
   bool Valid(int index) const{if(index<0||index>=m_count)return false;return m_valid[index];}
   string Reason(int index) const{if(index<0||index>=m_count)return "-";return m_reason[index];}
   string TypeText(int index) const{return TypeName(Type(index));}
};

#endif
