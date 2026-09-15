#property strict
#property version   "1.110"
#property description "ZGOLD - Zeus Gold Hedge Behavioral Reconstruction"
#property description "Forensic observers + controlled execution adapter"
#property description "Stage 98 - Configurable reconstruction"

input int    Magic=1001;
input double lot=0.01;
input double K_Lot=1.2;
input int    DigitsLot=2;
input double PlusLot=0.01;
input double Maxlot=0.62;
input int    MaxSpread=100;
input int    FirstStep=160;
input int    MinDistance=340;
input int    StepTrallOrders=50;
input int    Step=80;
input int    TwoStep=90;
input int    TwoMinDistance=80;
input double StopProfit=20.0;
input double CloseAll=4.0;
input double MaxLoss=100000.0;
input double MaxLossCloseAll=100.0;
input bool   EnableExecution=true;
input int    ExecutionMode=1;
input int    SlippagePoints=20;

#include "ZGOLD/Core/EAController.mqh"

EAController g_ea;

int OnInit()
{
   ZGoldParams::Configure(lot,K_Lot,PlusLot,DigitsLot,Maxlot,
                          FirstStep,MinDistance,StepTrallOrders,Step,TwoStep,TwoMinDistance,
                          StopProfit,CloseAll,MaxLoss,MaxLossCloseAll,MaxSpread,Magic);
   g_ea.SetMagic(Magic);
   g_ea.ConfigureExecution(EnableExecution,ExecutionMode,SlippagePoints);
   return g_ea.Initialize();
}

void OnTick(){g_ea.ProcessTick();}
void OnDeinit(const int reason){g_ea.Shutdown(reason);}
