#property strict
#property version   "0.1"
#property description "ZGOLD - Behavioral Reconstruction"
#property description "Fragment 03 - State + Pending + Debug Panel"
#property description "NO TRADING LOGIC"

input int Magic = 1001;

#include "ZGOLD/Core/EAController.mqh"

EAController g_ea;

int OnInit()
{
   return g_ea.Initialize(Magic);
}

void OnTick()
{
   g_ea.ProcessTick();
}

void OnDeinit(const int reason)
{
   g_ea.Shutdown(reason);
}
