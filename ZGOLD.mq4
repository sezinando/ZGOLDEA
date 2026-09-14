#property strict
#property version   "0.1"
#property description "ZGOLD - Behavioral Reconstruction"
#property description "Fragment 01 - Core + Debug Panel"
#property description "NO TRADING LOGIC"

#include "ZGOLD/Core/EAController.mqh"

EAController g_ea;

int OnInit()
{
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
