 /*!
     \file    main.c
 */

/*GD32 head file*/
 #include "gd32f4xx.h"
 //#include "gd32f450i_eval.h"
 #include "systick.h"
 #include <stdio.h>
 #include "stdint.h"
 #include "gd32f4xx_it.h"

 /* FreeRTOS head file */
//  #include "FreeRTOS.h"
//  #include "task.h"
//  #include "semphr.h"

/*ubt PCB head file*/
 #include "led.h"
 #include "usart_urbantoo.h"
 #include "ubt_motor.h"
 #include "bluetooth_protocol.h"
 #include "initialization.h"
 
////任务优先级声明
//#define Usart_Send_Task_PRIO    ( tskIDLE_PRIORITY + 4 )

////任务块函数声明
//void Usart_Send_Task(void * pvParameters);

//程序入口
 int main(void)
 {
		led_init();
		led1_open(G);
    usart_ubt_init(0,115200U);//GPIO转usart0初始化
		usart_dma_receive_config(USART0, USART_DENR_ENABLE);
    usart_ubt_init(3,115200U);//GPIO转usart3初始化
 		usart_ubt_init(2,115200U);//GPIO转usart2初始化
 		usart_ubt_init(1,115200U);//GPIO转usart1初始化
 		usart_ubt_init(4,115200U);//GPIO转usart4初始化
 		usart_ubt_init(5,9600U);//用于水弹发射
    nvic_irq_enable(USART0_IRQn, 0, 0);//usart中断优先级设置，信号的接收在中断中进行,任何中断类型都是这个
    usart_interrupt_enable(USART0, USART_INT_IDLE);//usart0空闲数据中断使能
	  dma_configuration();
	 // nvic_irq_enable(TIMER6_IRQn,1,1);//timer6基本定时器中断优先级设置
    timer_configuration(6);//timer6基本定时器初始化及使能中断，水弹发射50ms定时
		led2_open(R);
//		xTaskCreate(Usart_Send_Task, "Usart", configMINIMAL_STACK_SIZE, NULL, Usart_Send_Task_PRIO, NULL);
//		vTaskStartScheduler();
		while(1)
		{;}
 }

//void Usart_Send_Task(void * pvParameters)//发送数据的函数
//{
//	while(1)
//	{
//		vTaskDelay(5);//2ms执行一次。
//		if((bluetooth_signal.Key_Hval==0xFF)&&(bluetooth_signal.Key_Lval==0x00))
//		{
//			;
//		}
//		else
//		{
//			signal_process(motorusart);
//		}
//	}
//}





