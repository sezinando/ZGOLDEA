#ifndef __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__
#define __ZGOLD_PENDING_TRAILING_OBSERVER_MQH__

#include "../State/PendingState.mqh"

#define ZGOLD_TRAIL_NONE 0
#define ZGOLD_TRAIL_BUY  1
#define ZGOLD_TRAIL_SELL 2
#define ZGOLD_TRAIL_MAX  6

class PendingTrailingObserver
{
private:
   int    m_count;

   int    m_ticket0;
   int    m_ticket1;
   int    m_ticket2;
   int    m_ticket3;
   int    m_ticket4;
   int    m_ticket5;

   int    m_type0;
   int    m_type1;
   int    m_type2;
   int    m_type3;
   int    m_type4;
   int    m_type5;

   double m_oop0;
   double m_oop1;
   double m_oop2;
   double m_oop3;
   double m_oop4;
   double m_oop5;

   double m_market_ref0;
   double m_market_ref1;
   double m_market_ref2;
   double m_market_ref3;
   double m_market_ref4;
   double m_market_ref5;

   double m_candidate0;
   double m_candidate1;
   double m_candidate2;
   double m_candidate3;
   double m_candidate4;
   double m_candidate5;

   double m_delta0;
   double m_delta1;
   double m_delta2;
   double m_delta3;
   double m_delta4;
   double m_delta5;

   string m_distance_class0;
   string m_distance_class1;
   string m_distance_class2;
   string m_distance_class3;
   string m_distance_class4;
   string m_distance_class5;

   bool   m_valid0;
   bool   m_valid1;
   bool   m_valid2;
   bool   m_valid3;
   bool   m_valid4;
   bool   m_valid5;

   string m_reason0;
   string m_reason1;
   string m_reason2;
   string m_reason3;
   string m_reason4;
   string m_reason5;

   int GetTicket(int index) const
   {
      if(index==0) return m_ticket0;
      if(index==1) return m_ticket1;
      if(index==2) return m_ticket2;
      if(index==3) return m_ticket3;
      if(index==4) return m_ticket4;
      if(index==5) return m_ticket5;
      return -1;
   }

   void SetTicket(int index,int value)
   {
      if(index==0) m_ticket0=value;
      else if(index==1) m_ticket1=value;
      else if(index==2) m_ticket2=value;
      else if(index==3) m_ticket3=value;
      else if(index==4) m_ticket4=value;
      else if(index==5) m_ticket5=value;
   }

   int GetType(int index) const
   {
      if(index==0) return m_type0;
      if(index==1) return m_type1;
      if(index==2) return m_type2;
      if(index==3) return m_type3;
      if(index==4) return m_type4;
      if(index==5) return m_type5;
      return -1;
   }

   void SetType(int index,int value)
   {
      if(index==0) m_type0=value;
      else if(index==1) m_type1=value;
      else if(index==2) m_type2=value;
      else if(index==3) m_type3=value;
      else if(index==4) m_type4=value;
      else if(index==5) m_type5=value;
   }

   double GetOOP(int index) const
   {
      if(index==0) return m_oop0;
      if(index==1) return m_oop1;
      if(index==2) return m_oop2;
      if(index==3) return m_oop3;
      if(index==4) return m_oop4;
      if(index==5) return m_oop5;
      return 0.0;
   }

   void SetOOP(int index,double value)
   {
      if(index==0) m_oop0=value;
      else if(index==1) m_oop1=value;
      else if(index==2) m_oop2=value;
      else if(index==3) m_oop3=value;
      else if(index==4) m_oop4=value;
      else if(index==5) m_oop5=value;
   }

   double GetMarketRef(int index) const
   {
      if(index==0) return m_market_ref0;
      if(index==1) return m_market_ref1;
      if(index==2) return m_market_ref2;
      if(index==3) return m_market_ref3;
      if(index==4) return m_market_ref4;
      if(index==5) return m_market_ref5;
      return 0.0;
   }

   void SetMarketRef(int index,double value)
   {
      if(index==0) m_market_ref0=value;
      else if(index==1) m_market_ref1=value;
      else if(index==2) m_market_ref2=value;
      else if(index==3) m_market_ref3=value;
      else if(index==4) m_market_ref4=value;
      else if(index==5) m_market_ref5=value;
   }

   double GetCandidate(int index) const
   {
      if(index==0) return m_candidate0;
      if(index==1) return m_candidate1;
      if(index==2) return m_candidate2;
      if(index==3) return m_candidate3;
      if(index==4) return m_candidate4;
      if(index==5) return m_candidate5;
      return 0.0;
   }

   void SetCandidate(int index,double value)
   {
      if(index==0) m_candidate0=value;
      else if(index==1) m_candidate1=value;
      else if(index==2) m_candidate2=value;
      else if(index==3) m_candidate3=value;
      else if(index==4) m_candidate4=value;
      else if(index==5) m_candidate5=value;
   }

   double GetDelta(int index) const
   {
      if(index==0) return m_delta0;
      if(index==1) return m_delta1;
      if(index==2) return m_delta2;
      if(index==3) return m_delta3;
      if(index==4) return m_delta4;
      if(index==5) return m_delta5;
      return 0.0;
   }

   void SetDelta(int index,double value)
   {
      if(index==0) m_delta0=value;
      else if(index==1) m_delta1=value;
      else if(index==2) m_delta2=value;
      else if(index==3) m_delta3=value;
      else if(index==4) m_delta4=value;
      else if(index==5) m_delta5=value;
   }

   string GetDistanceClass(int index) const
   {
      if(index==0) return m_distance_class0;
      if(index==1) return m_distance_class1;
      if(index==2) return m_distance_class2;
      if(index==3) return m_distance_class3;
      if(index==4) return m_distance_class4;
      if(index==5) return m_distance_class5;
      return "-";
   }

   void SetDistanceClass(int index,string value)
   {
      if(index==0) m_distance_class0=value;
      else if(index==1) m_distance_class1=value;
      else if(index==2) m_distance_class2=value;
      else if(index==3) m_distance_class3=value;
      else if(index==4) m_distance_class4=value;
      else if(index==5) m_distance_class5=value;
   }

   bool GetValid(int index) const
   {
      if(index==0) return m_valid0;
      if(index==1) return m_valid1;
      if(index==2) return m_valid2;
      if(index==3) return m_valid3;
      if(index==4) return m_valid4;
      if(index==5) return m_valid5;
      return false;
   }

   void SetValid(int index,bool value)
   {
      if(index==0) m_valid0=value;
      else if(index==1) m_valid1=value;
      else if(index==2) m_valid2=value;
      else if(index==3) m_valid3=value;
      else if(index==4) m_valid4=value;
      else if(index==5) m_valid5=value;
   }

   string GetReason(int index) const
   {
      if(index==0) return m_reason0;
      if(index==1) return m_reason1;
      if(index==2) return m_reason2;
      if(index==3) return m_reason3;
      if(index==4) return m_reason4;
      if(index==5) return m_reason5;
      return "-";
   }

   void SetReason(int index,string value)
   {
      if(index==0) m_reason0=value;
      else if(index==1) m_reason1=value;
      else if(index==2) m_reason2=value;
      else if(index==3) m_reason3=value;
      else if(index==4) m_reason4=value;
      else if(index==5) m_reason5=value;
   }

   int FindOldTicket(int ticket,int old_count,const int &old_ticket0,const int &old_ticket1,const int &old_ticket2,const int &old_ticket3,const int &old_ticket4,const int &old_ticket5) const
   {
      if(old_count>0 && ticket==old_ticket0) return 0;
      if(old_count>1 && ticket==old_ticket1) return 1;
      if(old_count>2 && ticket==old_ticket2) return 2;
      if(old_count>3 && ticket==old_ticket3) return 3;
      if(old_count>4 && ticket==old_ticket4) return 4;
      if(old_count>5 && ticket==old_ticket5) return 5;
      return -1;
   }

   string InferDistanceFamily(double delta) const
   {
      if(MathAbs(delta-1.60)<=Point*2.0) return "FIRSTSTEP 1.60";
      if(MathAbs(delta-3.40)<=Point*2.0) return "MINDISTANCE 3.40";
      return "UNRESOLVED";
   }

   void EvaluateOne(int index,int ticket,int type,double oop,double bid,double ask,string prior_family)
   {
      SetTicket(index,ticket);
      SetType(index,type);
      SetOOP(index,oop);
      SetMarketRef(index,(type==OP_BUYSTOP?ask:bid));
      SetCandidate(index,GetMarketRef(index));
      SetDelta(index,0.0);
      SetDistanceClass(index,prior_family);
      SetValid(index,false);
      SetReason(index,"UNRESOLVED TYPE");

      if(type==OP_BUYSTOP)
      {
         SetDelta(index,oop-ask);
         SetValid(index,GetDelta(index)>=0.0);
         SetReason(index,"BUY STOP reference = ASK");
      }
      else if(type==OP_SELLSTOP)
      {
         SetDelta(index,bid-oop);
         SetValid(index,GetDelta(index)>=0.0);
         SetReason(index,"SELL STOP reference = BID");
      }
      else
      {
         SetDistanceClass(index,"UNRESOLVED");
         SetValid(index,false);
         return;
      }

      if(GetDistanceClass(index)=="UNRESOLVED")
         SetDistanceClass(index,InferDistanceFamily(GetDelta(index)));

      if(GetDistanceClass(index)!="UNRESOLVED")
         SetReason(index,GetReason(index)+" | FAMILY="+GetDistanceClass(index));
      else
         SetReason(index,GetReason(index)+" | FAMILY UNRESOLVED");
   }

public:
   PendingTrailingObserver(){Reset();}

   void Reset()
   {
      m_count=0;

      m_ticket0=-1; m_ticket1=-1; m_ticket2=-1; m_ticket3=-1; m_ticket4=-1; m_ticket5=-1;
      m_type0=-1; m_type1=-1; m_type2=-1; m_type3=-1; m_type4=-1; m_type5=-1;
      m_oop0=0.0; m_oop1=0.0; m_oop2=0.0; m_oop3=0.0; m_oop4=0.0; m_oop5=0.0;
      m_market_ref0=0.0; m_market_ref1=0.0; m_market_ref2=0.0; m_market_ref3=0.0; m_market_ref4=0.0; m_market_ref5=0.0;
      m_candidate0=0.0; m_candidate1=0.0; m_candidate2=0.0; m_candidate3=0.0; m_candidate4=0.0; m_candidate5=0.0;
      m_delta0=0.0; m_delta1=0.0; m_delta2=0.0; m_delta3=0.0; m_delta4=0.0; m_delta5=0.0;
      m_distance_class0="UNRESOLVED"; m_distance_class1="UNRESOLVED"; m_distance_class2="UNRESOLVED"; m_distance_class3="UNRESOLVED"; m_distance_class4="UNRESOLVED"; m_distance_class5="UNRESOLVED";
      m_valid0=false; m_valid1=false; m_valid2=false; m_valid3=false; m_valid4=false; m_valid5=false;
      m_reason0="NO PENDING"; m_reason1="NO PENDING"; m_reason2="NO PENDING"; m_reason3="NO PENDING"; m_reason4="NO PENDING"; m_reason5="NO PENDING";
   }

   void EvaluateAll(PendingState &p,double bid,double ask)
   {
      int old_count=m_count;
      int old_ticket0=m_ticket0;
      int old_ticket1=m_ticket1;
      int old_ticket2=m_ticket2;
      int old_ticket3=m_ticket3;
      int old_ticket4=m_ticket4;
      int old_ticket5=m_ticket5;

      string old_family0=m_distance_class0;
      string old_family1=m_distance_class1;
      string old_family2=m_distance_class2;
      string old_family3=m_distance_class3;
      string old_family4=m_distance_class4;
      string old_family5=m_distance_class5;

      int total=p.Count();
      if(total>ZGOLD_TRAIL_MAX) total=ZGOLD_TRAIL_MAX;

      m_count=0;
      m_ticket0=-1; m_ticket1=-1; m_ticket2=-1; m_ticket3=-1; m_ticket4=-1; m_ticket5=-1;
      m_type0=-1; m_type1=-1; m_type2=-1; m_type3=-1; m_type4=-1; m_type5=-1;
      m_oop0=0.0; m_oop1=0.0; m_oop2=0.0; m_oop3=0.0; m_oop4=0.0; m_oop5=0.0;
      m_market_ref0=0.0; m_market_ref1=0.0; m_market_ref2=0.0; m_market_ref3=0.0; m_market_ref4=0.0; m_market_ref5=0.0;
      m_candidate0=0.0; m_candidate1=0.0; m_candidate2=0.0; m_candidate3=0.0; m_candidate4=0.0; m_candidate5=0.0;
      m_delta0=0.0; m_delta1=0.0; m_delta2=0.0; m_delta3=0.0; m_delta4=0.0; m_delta5=0.0;
      m_distance_class0="UNRESOLVED"; m_distance_class1="UNRESOLVED"; m_distance_class2="UNRESOLVED"; m_distance_class3="UNRESOLVED"; m_distance_class4="UNRESOLVED"; m_distance_class5="UNRESOLVED";
      m_valid0=false; m_valid1=false; m_valid2=false; m_valid3=false; m_valid4=false; m_valid5=false;
      m_reason0="NO PENDING"; m_reason1="NO PENDING"; m_reason2="NO PENDING"; m_reason3="NO PENDING"; m_reason4="NO PENDING"; m_reason5="NO PENDING";

      for(int i=0;i<total;i++)
      {
         int ticket=p.Ticket(i);
         int old_index=FindOldTicket(ticket,old_count,old_ticket0,old_ticket1,old_ticket2,old_ticket3,old_ticket4,old_ticket5);
         string family="UNRESOLVED";
         if(old_index==0) family=old_family0;
         else if(old_index==1) family=old_family1;
         else if(old_index==2) family=old_family2;
         else if(old_index==3) family=old_family3;
         else if(old_index==4) family=old_family4;
         else if(old_index==5) family=old_family5;

         EvaluateOne(i,ticket,p.Type(i),p.Price(i),bid,ask,family);
      }

      m_count=total;
   }

   int Count() const{return m_count;}
   int Ticket(int index) const{if(index<0||index>=m_count)return -1;return GetTicket(index);}
   int Type(int index) const{if(index<0||index>=m_count)return -1;return GetType(index);}
   double OOP(int index) const{if(index<0||index>=m_count)return 0.0;return GetOOP(index);}
   double MarketReference(int index) const{if(index<0||index>=m_count)return 0.0;return GetMarketRef(index);}
   double Candidate(int index) const{if(index<0||index>=m_count)return 0.0;return GetCandidate(index);}
   double Delta(int index) const{if(index<0||index>=m_count)return 0.0;return GetDelta(index);}
   string DistanceClass(int index) const{if(index<0||index>=m_count)return "-";return GetDistanceClass(index);}
   bool Valid(int index) const{if(index<0||index>=m_count)return false;return GetValid(index);}
   string Reason(int index) const{if(index<0||index>=m_count)return "-";return GetReason(index);}
   string TypeText(int index) const
   {
      int type=Type(index);
      if(type==OP_BUYSTOP) return "BUY STOP";
      if(type==OP_SELLSTOP) return "SELL STOP";
      return "UNKNOWN";
   }
};

#endif
