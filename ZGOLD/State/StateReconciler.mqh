#ifndef __ZGOLD_STATE_RECONCILER_MQH__
#define __ZGOLD_STATE_RECONCILER_MQH__
#include "ExposureState.mqh"
#include "PendingState.mqh"
#include "LifecycleState.mqh"
class StateReconciler
{
private:
 ExposureState m_exposure; PendingState m_pending; LifecycleState m_lifecycle; int m_magic;
public:
 StateReconciler(){m_magic=1001;}
 void SetMagic(int magic){m_magic=magic;}
 bool Reconcile(){int bc=0,sc=0;double bl=0,sl=0,bp=0,sp=0;m_pending.Reset();m_lifecycle.Reconcile(m_magic);for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=m_magic)continue;int t=OrderType();if(t==OP_BUY){bc++;bl+=OrderLots();bp+=OrderProfit()+OrderSwap()+OrderCommission();}else if(t==OP_SELL){sc++;sl+=OrderLots();sp+=OrderProfit()+OrderSwap()+OrderCommission();}else if(t==OP_BUYSTOP||t==OP_SELLSTOP||t==OP_BUYLIMIT||t==OP_SELLLIMIT)m_pending.Add(OrderTicket(),t,OrderLots(),OrderOpenPrice());}m_exposure.Reset();m_exposure.SetBuy(bc,bl,bp);m_exposure.SetSell(sc,sl,sp);m_exposure.Finalize();return true;}
 void CopyExposureTo(ExposureState &target){target.Reset();target.SetBuy(m_exposure.BuyCount(),m_exposure.BuyLots(),m_exposure.BuyProfit());target.SetSell(m_exposure.SellCount(),m_exposure.SellLots(),m_exposure.SellProfit());target.Finalize();}
 void CopyPendingTo(PendingState &target){target.Reset();for(int i=0;i<m_pending.Count();i++)target.Add(m_pending.Ticket(i),m_pending.Type(i),m_pending.Lots(i),m_pending.Price(i));}
 int LifecycleEvent()const{return m_lifecycle.Event();}
 int LifecycleTicket()const{return m_lifecycle.Ticket();}
 int LifecyclePreviousType()const{return m_lifecycle.PreviousType();}
 int LifecycleType()const{return m_lifecycle.Type();}
 double LifecyclePreviousLots()const{return m_lifecycle.PreviousLots();}
 double LifecycleLots()const{return m_lifecycle.Lots();}
 double LifecyclePreviousPrice()const{return m_lifecycle.PreviousPrice();}
 double LifecyclePrice()const{return m_lifecycle.Price();}
 string LifecycleText()const{return m_lifecycle.EventText();}
};
#endif
