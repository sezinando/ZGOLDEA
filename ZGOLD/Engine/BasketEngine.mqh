#ifndef __ZGOLD_BASKET_ENGINE_MQH__
#define __ZGOLD_BASKET_ENGINE_MQH__
#include "../State/ExposureState.mqh"
#include "../Config/ZGoldParams.mqh"
#define ZGOLD_BASKET_NONE 0
#define ZGOLD_BASKET_BUY 1
#define ZGOLD_BASKET_SELL 2
#define ZGOLD_BASKET_MAX_POS 64
class BasketEngine
{
private:int m_direction,m_count;double m_profit,m_target,m_progress;int m_tickets[ZGOLD_BASKET_MAX_POS];double m_lots[ZGOLD_BASKET_MAX_POS],m_open_price[ZGOLD_BASKET_MAX_POS],m_pl[ZGOLD_BASKET_MAX_POS];bool m_triggered;string m_reason;
 void ResetArrays(){for(int i=0;i<ZGOLD_BASKET_MAX_POS;i++){m_tickets[i]=-1;m_lots[i]=0;m_open_price[i]=0;m_pl[i]=0;}}
 void EvaluateDirection(int d,int magic){int n=0;double profit=0;for(int i=OrdersTotal()-1;i>=0&&n<ZGOLD_BASKET_MAX_POS;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=magic)continue;if((d==OP_BUY&&OrderType()!=OP_BUY)||(d==OP_SELL&&OrderType()!=OP_SELL))continue;m_tickets[n]=OrderTicket();m_lots[n]=OrderLots();m_open_price[n]=OrderOpenPrice();m_pl[n]=OrderProfit()+OrderSwap()+OrderCommission();profit+=m_pl[n];n++;}if(n<=0)return;double target=n*ZGoldParams::StopProfit();double progress=target>0?profit/target:0;if(!m_triggered||progress>m_progress){m_direction=(d==OP_BUY?ZGOLD_BASKET_BUY:ZGOLD_BASKET_SELL);m_count=n;m_profit=profit;m_target=target;m_progress=progress;if(profit>=target)m_triggered=true;}if(profit>=target)m_reason="DIRECTIONAL PROFIT >= COUNT*STOPPROFIT";}
public:BasketEngine(){Reset();}void Reset(){m_direction=ZGOLD_BASKET_NONE;m_count=0;m_profit=0;m_target=0;m_progress=0;m_triggered=false;m_reason="NO BASKET TRIGGER";ResetArrays();}void Evaluate(ExposureState &e,int magic){Reset();EvaluateDirection(OP_BUY,magic);EvaluateDirection(OP_SELL,magic);}bool Triggered()const{return m_triggered;}int Direction()const{return m_direction;}int Count()const{return m_count;}double Profit()const{return m_profit;}double Target()const{return m_target;}double Progress()const{return m_progress;}string Reason()const{return m_reason;}int Ticket(int i)const{return(i>=0&&i<m_count)?m_tickets[i]:-1;}double Lots(int i)const{return(i>=0&&i<m_count)?m_lots[i]:0;}double OpenPrice(int i)const{return(i>=0&&i<m_count)?m_open_price[i]:0;}double ProfitByPosition(int i)const{return(i>=0&&i<m_count)?m_pl[i]:0;}
};
#endif
