#ifndef __ZGOLD_GEOMETRY_OBSERVER_MQH__
#define __ZGOLD_GEOMETRY_OBSERVER_MQH__
#include "../State/ExposureState.mqh"
#include "../State/PendingState.mqh"
#include "../Config/ZGoldParams.mqh"
#define ZGOLD_GEOMETRY_VALID 1
#define ZGOLD_GEOMETRY_BLOCKED 2
#define ZGOLD_GEOMETRY_UNRESOLVED 3
class GeometryObserver
{
private:string m_status,m_reason;double m_step_distance,m_two_step_distance,m_candidate;int m_direction;
public:
 GeometryObserver(){Reset();}
 void Reset(){m_status="UNRESOLVED";m_reason="NOT EVALUATED";m_step_distance=ZGoldParams::Step();m_two_step_distance=ZGoldParams::TwoStep();m_candidate=0;m_direction=-1;}
 void Evaluate(double candidate,int direction,ExposureState &e,PendingState &p){m_candidate=candidate;m_direction=direction;m_status="UNRESOLVED";m_reason="NO PROVEN REFERENCE RULE";m_step_distance=ZGoldParams::Step();m_two_step_distance=ZGoldParams::TwoStep();if(candidate<=0){m_reason="INVALID CANDIDATE";return;}double nearest=0;bool has=false;for(int i=0;i<p.Count();i++){if((direction==OP_BUY&&p.Type(i)==OP_BUYSTOP)||(direction==OP_SELL&&p.Type(i)==OP_SELLSTOP)){double d=MathAbs(candidate-p.Price(i));if(!has||d<nearest){nearest=d;has=true;}}}if(has&&nearest<Point*ZGoldParams::PendingConflictPoints()){m_status="BLOCKED";m_reason="SAME-DIRECTION PENDING TOO CLOSE";return;}m_status="VALID";m_reason="GEOMETRY NOT IN CONFLICT";}
 string Status()const{return m_status;}string Reason()const{return m_reason;}double StepDistance()const{return m_step_distance;}double TwoStepDistance()const{return m_two_step_distance;}double Candidate()const{return m_candidate;}int Direction()const{return m_direction;}
};
#endif
