#ifndef __ZGOLD_PARAMS_MQH__
#define __ZGOLD_PARAMS_MQH__

// Runtime configuration for the reconstructed Zeus Gold Hedge behavior.
// All distance inputs are MT4 points; geometry methods convert points to price.
// The unresolved layer selector is intentionally kept out of execution logic.
class ZGoldParams
{
private:
   static double s_lot,s_klot,s_pluslot,s_maxlot;
   static int s_digitslot;
   static int s_firststep,s_mindistance,s_steptrall,s_step,s_twostep,s_twomindistance;
   static double s_stopprofit,s_closeall,s_maxloss,s_maxlosscloseall;
   static int s_maxspread,s_magic;
public:
   static void Configure(double lot,double klot,double pluslot,int digitslot,double maxlot,
                         int firststep,int mindistance,int steptrall,int step,int twostep,int twomindistance,
                         double stopprofit,double closeall,double maxloss,double maxlosscloseall,int maxspread,int magic)
   {
      s_lot=lot; s_klot=klot; s_pluslot=pluslot; s_digitslot=digitslot; s_maxlot=maxlot;
      s_firststep=firststep; s_mindistance=mindistance; s_steptrall=steptrall;
      s_step=step; s_twostep=twostep; s_twomindistance=twomindistance;
      s_stopprofit=stopprofit; s_closeall=closeall; s_maxloss=maxloss; s_maxlosscloseall=maxlosscloseall;
      s_maxspread=s_maxspread; s_magic=magic;
   }
   static double Lot(){return s_lot;}
   static double KLot(){return s_klot;}
   static double PlusLot(){return s_pluslot;}
   static int DigitsLot(){return s_digitslot;}
   static double MaxLot(){return s_maxlot;}
   static double FirstStep(){return s_firststep*Point;}
   static double MinDistance(){return s_mindistance*Point;}
   static double StepTrallOrders(){return s_steptrall*Point;}
   static double Step(){return s_step*Point;}
   static double TwoStep(){return s_twostep*Point;}
   static double TwoMinDistance(){return s_twomindistance*Point;}
   static double StopProfit(){return s_stopprofit;}
   static double CloseAllThreshold(){return s_closeall;}
   static double MaxLoss(){return s_maxloss;}
   static double MaxLossCloseAll(){return s_maxlosscloseall;}
   static int MaxSpreadPoints(){return s_maxspread;}
   static int PendingConflictPoints(){return 5;}
   static int CompressionMinCount(){return 3;}
   static double CompressionLotMultiplier(){return 3.0;}
   static int Magic(){return s_magic;}
};

double ZGoldParams::s_lot=0.01;
double ZGoldParams::s_klot=1.2;
double ZGoldParams::s_pluslot=0.01;
int    ZGoldParams::s_digitslot=2;
double ZGoldParams::s_maxlot=0.62;
int    ZGoldParams::s_firststep=160;
int    ZGoldParams::s_mindistance=340;
int    ZGoldParams::s_steptrall=50;
int    ZGoldParams::s_step=80;
int    ZGoldParams::s_twostep=90;
int    ZGoldParams::s_twomindistance=80;
double ZGoldParams::s_stopprofit=20.0;
double ZGoldParams::s_closeall=4.0;
double ZGoldParams::s_maxloss=100000.0;
double ZGoldParams::s_maxlosscloseall=100.0;
int    ZGoldParams::s_maxspread=100;
int    ZGoldParams::s_magic=1001;

#endif
