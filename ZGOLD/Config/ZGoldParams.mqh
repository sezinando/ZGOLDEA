#ifndef __ZGOLD_PARAMS_MQH__
#define __ZGOLD_PARAMS_MQH__

// Reconstructed Zeus Gold Hedge V1.2 baseline.
// Status: COMPROVADO / HIPOTESE FORTE / NAO_DETERMINADO / IMPLEMENTACAO.
class ZGoldParams
{
public:
   static double Lot(){return 0.01;}
   static double KLot(){return 1.2;}
   static double PlusLot(){return 0.01;}
   static int DigitsLot(){return 2;}
   static double MaxLot(){return 0.62;}

   static double FirstStep(){return 1.60;}
   static double MinDistance(){return 3.40;}
   static double StepTrallOrders(){return 0.50;}

   static double Step(){return 0.80;}
   static double TwoStep(){return 0.90;}
   static double TwoMinDistance(){return 0.80;}

   static double StopProfit(){return 20.0;}
   static double CloseAllThreshold(){return 4.0;}

   static double CompressionLotMultiplier(){return 3.0;}
   static int CompressionMinCount(){return 3;}

   static double MaxLoss(){return 100000.0;}
   static double MaxLossCloseAll(){return 100.0;}
   static int MaxSpreadPoints(){return 100;}

   // IMPLEMENTACAO: not observed as an original Zeus input.
   static int PendingConflictPoints(){return 5;}
   static int Magic(){return 1001;}
};

#endif
