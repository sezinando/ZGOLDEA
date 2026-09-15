#ifndef __ZGOLD_LOT_ENGINE_MQH__
#define __ZGOLD_LOT_ENGINE_MQH__

class LotEngine
{
private:
   double m_base_lot;
   double m_k_lot;
   double m_plus_lot;
   int    m_digits_lot;
   double m_max_lot;

   int m_buy_level;
   int m_sell_level;
   double m_buy_next_lot;
   double m_sell_next_lot;

   double Calculate(int n)
   {
      double lot = m_base_lot * MathPow(m_k_lot,n) + n * m_plus_lot;
      lot = NormalizeDouble(lot,m_digits_lot);
      if(lot > m_max_lot) lot = m_max_lot;
      return NormalizeDouble(lot,m_digits_lot);
   }

public:
   LotEngine()
   {
      Configure(0.01,1.2,0.01,2,0.62);
      Reset();
   }

   void Configure(double base_lot,double k_lot,double plus_lot,int digits_lot,double max_lot)
   {
      m_base_lot=base_lot;
      m_k_lot=k_lot;
      m_plus_lot=plus_lot;
      m_digits_lot=digits_lot;
      m_max_lot=max_lot;
   }

   void Reset()
   {
      m_buy_level=0;
      m_sell_level=0;
      m_buy_next_lot=Calculate(0);
      m_sell_next_lot=Calculate(0);
   }

   void ResetBuy()
   {
      m_buy_level=0;
      m_buy_next_lot=Calculate(0);
   }

   void ResetSell()
   {
      m_sell_level=0;
      m_sell_next_lot=Calculate(0);
   }

   void SyncFromCounts(int buy_count,int sell_count)
   {
      if(buy_count<=0) ResetBuy();
      else
      {
         m_buy_level=buy_count;
         m_buy_next_lot=Calculate(m_buy_level);
      }
      if(sell_count<=0) ResetSell();
      else
      {
         m_sell_level=sell_count;
         m_sell_next_lot=Calculate(m_sell_level);
      }
   }

   double LotForLevel(int level) const
   {
      if(level<0) level=0;
      double lot=m_base_lot*MathPow(m_k_lot,level)+level*m_plus_lot;
      lot=NormalizeDouble(lot,m_digits_lot);
      if(lot>m_max_lot) lot=m_max_lot;
      return NormalizeDouble(lot,m_digits_lot);
   }

   double BuyNextLot() const { return m_buy_next_lot; }
   double SellNextLot() const { return m_sell_next_lot; }
   int BuyLevel() const { return m_buy_level; }
   int SellLevel() const { return m_sell_level; }
   double BaseLot() const { return m_base_lot; }
   double KLot() const { return m_k_lot; }
   double PlusLot() const { return m_plus_lot; }
   int DigitsLot() const { return m_digits_lot; }
   double MaxLot() const { return m_max_lot; }
};

#endif
