#property strict
#property version   "0.100"
#property description "ZGOLD - Behavioral Reconstruction"
#property description "Fragment 03 - State + Pending + Lifecycle + Debug Panel"
#property description "NO TRADING LOGIC"

input int Magic = 1001;

#include "ZGOLD/Core/EAController.mqh"

EAController g_ea;

int OnInit()
{
   g_ea.SetMagic(Magic);
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
