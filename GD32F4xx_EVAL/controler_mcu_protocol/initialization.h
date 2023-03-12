/*≥ı ºªØ*/
#ifndef _initialization_h
#define _initialization_h
#include "stdint.h"
#include "gd32f4xx.h"
#include <stdio.h>

void timer_configuration(char com);

static rcu_periph_enum RCU_timer_num[14]={RCU_TIMER0,RCU_TIMER1,RCU_TIMER2,RCU_TIMER3,RCU_TIMER4,RCU_TIMER5,RCU_TIMER6,RCU_TIMER7,RCU_TIMER8,RCU_TIMER9,RCU_TIMER10,RCU_TIMER11,RCU_TIMER12,RCU_TIMER13};
static uint32_t timer_num[14]={TIMER0,TIMER1,TIMER2,TIMER3,TIMER4,TIMER5,TIMER6,TIMER7,TIMER8,TIMER9,TIMER10,TIMER11,TIMER12,TIMER13};

#endif

