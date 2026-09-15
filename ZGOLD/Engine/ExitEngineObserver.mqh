#ifndef __ZGOLD_EXIT_ENGINE_OBSERVER_MQH__
#define __ZGOLD_EXIT_ENGINE_OBSERVER_MQH__
#include "../State/ExposureState.mqh"
#include "../Config/ZGoldParams.mqh"
#define ZGOLD_EXIT_NONE 0
#define ZGOLD_EXIT_BASKET 1
#define ZGOLD_EXIT_COMPRESSION 2
#define ZGOLD_EXIT_GLOBAL 3
#define ZGOLD_EXIT_MAX_POS 64
class ExitEngineObserver
{
private:
 bool m_buy_basket,m_sell_basket,m_buy_compression,m_sell_compression,m_global_triggered,m_capacity_warning;
 double m_buy_profit,m_sell_profit,m_buy_target,m_sell_target,m_total_profit;
 int m_buy_winner,m_buy_loss1,m_buy_loss2,m_sell_winner,m_sell_loss1,m_sell_loss2;
 double m_buy_result,m_sell_result,m_buy_winner_profit,m_sell_winner_profit;
 void EvalBasket(int d,int magic,bool &trig,double &profit,double &target)
 {
    int n=0; profit=0;
    for(int i=OrdersTotal()-1;i>=0;i--){
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
       if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=magic)continue;
       int t=OrderType();
       if((d==OP_BUY&&t!=OP_BUY)||(d==OP_SELL&&t!=OP_SELL))continue;
       n++; profit+=OrderProfit()+OrderSwap()+OrderCommission();
    }
    target=n*ZGoldParams::StopProfit();
    trig=(n>0&&profit>=target);
 }
 void EvalComp(int d,int magic,double side,double opp,bool &trig,int &winT,int &l1T,int &l2T,double &winP,double &result)
 {
    int tk[ZGOLD_EXIT_MAX_POS]; double pf[ZGOLD_EXIT_MAX_POS]; int n=0; int total_seen=0;
    trig=false; winT=l1T=l2T=-1; winP=0; result=0;
    for(int i=OrdersTotal()-1;i>=0;i--){
       if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
       if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=magic)continue;
       int t=OrderType();
       if((d==OP_BUY&&t!=OP_BUY)||(d==OP_SELL&&t!=OP_SELL))continue;
       total_seen++;
       if(n<ZGOLD_EXIT_MAX_POS){tk[n]=OrderTicket();pf[n]=OrderProfit()+OrderSwap()+OrderCommission();n++;}
    }
    if(total_seen>ZGOLD_EXIT_MAX_POS)m_capacity_warning=true;
    if(n<=ZGoldParams::CompressionMinCount())return;
    int w=0; for(int j=1;j<n;j++)if(pf[j]>pf[w])w=j;
    int a=-1,b=-1;
    for(int k=0;k<n;k++){
       if(k==w)continue;
       if(a<0||pf[k]<pf[a]){b=a;a=k;}
       else if(b<0||pf[k]<pf[b])b=k;
    }
    if(a<0||b<0)return;
    double do32=pf[w]+pf[a]+pf[b];
    double winnerLots=OrderLotsByTicket(tk[w],magic);
    // winner > 0 is intentionally NOT a separate eligibility gate.
    // Under the formal do32 model it is redundant; kept only as an invariant comment.
    if(winnerLots>0 && side>opp+ZGoldParams::CompressionLotMultiplier()*winnerLots && do32>0)
    {trig=true;winT=tk[w];l1T=tk[a];l2T=tk[b];winP=pf[w];result=do32;}
 }
 double OrderLotsByTicket(int ticket,int magic){if(ticket<0)return 0;for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderTicket()==ticket)return OrderLots();}return 0;}
public:
 ExitEngineObserver(){Reset();}
 void Reset(){m_buy_basket=m_sell_basket=m_buy_compression=m_sell_compression=m_global_triggered=m_capacity_warning=false;m_buy_profit=m_sell_profit=m_buy_target=m_sell_target=m_total_profit=0;m_buy_winner=m_buy_loss1=m_buy_loss2=m_sell_winner=m_sell_loss1=m_sell_loss2=-1;m_buy_result=m_sell_result=m_buy_winner_profit=m_sell_winner_profit=0;}
 void Evaluate(ExposureState &e,int magic){Reset();m_total_profit=e.TotalProfit();m_global_triggered=(m_total_profit>=ZGoldParams::CloseAllThreshold());EvalBasket(OP_BUY,magic,m_buy_basket,m_buy_profit,m_buy_target);EvalBasket(OP_SELL,magic,m_sell_basket,m_sell_profit,m_sell_target);EvalComp(OP_BUY,magic,e.BuyLots(),e.SellLots(),m_buy_compression,m_buy_winner,m_buy_loss1,m_buy_loss2,m_buy_winner_profit,m_buy_result);EvalComp(OP_SELL,magic,e.SellLots(),e.BuyLots(),m_sell_compression,m_sell_winner,m_sell_loss1,m_sell_loss2,m_sell_winner_profit,m_sell_result);}
 bool BuyBasketEligible()const{return m_buy_basket;} bool SellBasketEligible()const{return m_sell_basket;} bool BuyCompressionEligible()const{return m_buy_compression;} bool SellCompressionEligible()const{return m_sell_compression;} bool GlobalTriggered()const{return m_global_triggered;} bool CapacityWarning()const{return m_capacity_warning;}
 int ExitGateCount()const{return (m_buy_basket?1:0)+(m_sell_basket?1:0)+(m_buy_compression?1:0)+(m_sell_compression?1:0)+(m_global_triggered?1:0);}
 bool MultipleExitGatesEligible()const{return ExitGateCount()>1;}
 int BasketDirection()const{if(m_buy_basket&&!m_sell_basket)return OP_BUY;if(m_sell_basket&&!m_buy_basket)return OP_SELL;return -1;} double BasketProfit()const{return (m_buy_basket?m_buy_profit:(m_sell_basket?m_sell_profit:0));} double BasketTarget()const{return (m_buy_basket?m_buy_target:(m_sell_basket?m_sell_target:0));}
 bool BasketTriggered()const{return m_buy_basket||m_sell_basket;} double TotalProfit()const{return m_total_profit;}
 bool CompressionTriggered()const{return m_buy_compression||m_sell_compression;} int CompressionDirection()const{if(m_buy_compression&&!m_sell_compression)return OP_BUY;if(m_sell_compression&&!m_buy_compression)return OP_SELL;return -1;} int CompressionCount()const{return CompressionTriggered()?3:0;}
 int WinnerTicket()const{return m_buy_compression?m_buy_winner:(m_sell_compression?m_sell_winner:-1);} double WinnerProfit()const{return m_buy_compression?m_buy_winner_profit:(m_sell_compression?m_sell_winner_profit:0);} int Loss1Ticket()const{return m_buy_compression?m_buy_loss1:(m_sell_compression?m_sell_loss1:-1);} int Loss2Ticket()const{return m_buy_compression?m_buy_loss2:(m_sell_compression?m_sell_loss2:-1);} double CompressionResult()const{return m_buy_compression?m_buy_result:(m_sell_compression?m_sell_result:0);}
};
#endif
