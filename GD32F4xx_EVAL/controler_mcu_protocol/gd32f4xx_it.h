

#ifndef GD32F4XX_IT_H
#define GD32F4XX_IT_H

#include "gd32f4xx.h"

//电机串口号
#define motorusart 1


/* function declarations */
/* this function handles NMI exception */
void NMI_Handler(void);
/* this function handles HardFault exception */
void HardFault_Handler(void);
/* this function handles MemManage exception */
void MemManage_Handler(void);
/* this function handles BusFault exception */
void BusFault_Handler(void);
/* this function handles UsageFault exception */
void UsageFault_Handler(void);
/* this function handles SVC exception */
void SVC_Handler(void);
/* this function handles DebugMon exception */
void DebugMon_Handler(void);
/* this function handles PendSV exception */
void PendSV_Handler(void);
/* this function handles SysTick exception */
void SysTick_Handler(void);
/* this function handles USART0 exception */
void USART0_IRQHandler(void);
/* this function handles TIMER2 exception */
void TIMER2_IRQHandler(void);
#endif /* GD32F4XX_IT_H */
