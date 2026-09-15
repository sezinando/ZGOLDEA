#property strict
#property version   "1.100"
#property description "ZGOLD - Zeus Gold Hedge Behavioral Reconstruction"
#property description "Forensic observers + controlled execution adapter"
#property description "Stage 97 - Strategy Tester ready"

input int  Magic = 1001;
input bool EnableExecution = true;
input int  ExecutionMode = 1;
input int  SlippagePoints = 20;

#include "ZGOLD/Core/EAController.mqh"

EAController g_ea;

int OnInit()
{
   g_ea.SetMagic(Magic);
   g_ea.ConfigureExecution(EnableExecution,ExecutionMode,SlippagePoints);
   return g_ea.Initialize();
}

void OnTick()
{
   g_ea.ProcessTick();
}

void OnDeinit(const int reason)
{
   g_ea.Shutdown(reason);
}
