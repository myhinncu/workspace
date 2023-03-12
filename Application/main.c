 /*!
     \file    main.c
 */

/*GD32 head file*/
  #include "gd32f4xx.h"
//#include "gd32f450i_eval.h"
  #include "systick.h"
//#include <stdio.h>
  #include "stdint.h"
// #include "gd32f4xx_it.h"
  #include "key.h"
 /* FreeRTOS head file */
  #include "FreeRTOS.h"
  #include "task.h"
  #include "semphr.h"

/*ubt PCB head file*/
	#include "led.h"
// #include "usart_urbantoo.h"
// #include "ubt_motor.h"
// #include "bluetooth_protocol.h"
// #include "initialization.h"
 
//任务优先级声明
#define LED1_TASK_PRIO ( tskIDLE_PRIORITY + 2 )
#define LED2_TASK_PRIO ( tskIDLE_PRIORITY + 1 )
#define KEY1_TASK_PRIO ( tskIDLE_PRIORITY + 3 )
void LED1_task(void * pvParameters);
void LED2_task(void * pvParameters);
void KEY1_task(void * pvParameters);
static TaskHandle_t LED1_task_Handle = NULL;
static TaskHandle_t LED2_task_Handle = NULL;


//任务块函数声明
//void Usart_Send_Task(void * pvParameters);

//程序入口
 int main(void)
 {
	/*中断地址偏移0x40000.调试时要注释，生成bin文件时添加，且app开始地址改为0x8040000,大小改为0x40000*/
//  nvic_vector_table_set(NVIC_VECTTAB_FLASH,0x40000);
		nvic_priority_group_set(NVIC_PRIGROUP_PRE4_SUB0);
		led_init();
		key_init();
//  led1_open(R);//led1绿色
//	vTaskDelay(1000);
//	led1_close(R);
		xTaskCreate(LED1_task, "LED1", configMINIMAL_STACK_SIZE, NULL, LED1_TASK_PRIO, &LED1_task_Handle);
		xTaskCreate(LED2_task, "LED2", configMINIMAL_STACK_SIZE, NULL, LED2_TASK_PRIO, &LED2_task_Handle);
		xTaskCreate(KEY1_task, "KEY1", configMINIMAL_STACK_SIZE, NULL, KEY1_TASK_PRIO, NULL);
	/*硬件与外设使能*/
		vTaskStartScheduler();
     while (1)
     {
 			;
     }
 }
 
	void LED1_task(void * pvParameters)
	{  
		 while(1){
					/* toggle LED2 each 500ms */
					led2_open(G);
					vTaskDelay(1000);
					led2_close(G);
					vTaskDelay(1000);
			}
	}

	void LED2_task(void * pvParameters)
	{  
		 while(1){
					/* toggle LED2 each 500ms */
					led1_open(B);
					vTaskDelay(1000);
					led1_close(B);
					vTaskDelay(1000);
			}
	}
	
void KEY1_task(void * pvParameters)
{  
		static uint8_t FLAG_BIT=1;
		while(1)
		{
		vTaskDelay(50);
		if(key_left()==RESET)
			{
					if(FLAG_BIT==1)
					{
						vTaskSuspend(LED1_task_Handle);
						FLAG_BIT=0;
					}
					else if(FLAG_BIT==0)
					{
						vTaskResume(LED1_task_Handle);
						FLAG_BIT=1;							
					}
      }
		}	
}		
//}按键控制任务启停
	
//		void KEY2_task(void * pvParameters)
//		{  
//		    while(1){
//				/* toggle LED2 each 500ms */
//				led1_open(B);
//				vTaskDelay(500);
//				led1_close(B);
//				vTaskDelay(500);
//		}
//		}	
 
 
 //下列代码是使用FreeRTOS使LED亮灭的基本测试程序
//#define LED1_TASK_PRIO    ( tskIDLE_PRIORITY + 2 )
//#define LED2_TASK_PRIO    ( tskIDLE_PRIORITY + 1 )

//void LED1_task(void * pvParameters);
//void LED2_task(void * pvParameters);
//	
//int main(void)
//{
//	/* 设置优先级分组为4,16个优先级全是抢占优先级 */
//   nvic_priority_group_set(NVIC_PRIGROUP_PRE4_SUB0);
//	led_init();
//	//led1_open(B);
//	xTaskCreate(LED1_task, "LED1", configMINIMAL_STACK_SIZE, NULL, LED1_TASK_PRIO, NULL);
//	xTaskCreate(LED2_task, "LED2", configMINIMAL_STACK_SIZE, NULL, LED1_TASK_PRIO, NULL);
//	/* start scheduler */
//    vTaskStartScheduler();
//    while(1){
//    }
//}
//void LED1_task(void * pvParameters)
//{  
//   while(1){
//        /* toggle LED2 each 500ms */
//        led2_open(G);
//        vTaskDelay(1000);
//				led2_close(G);
//				vTaskDelay(1000);
//    }
//}

//void LED2_task(void * pvParameters)
//{  
//   while(1){
//        /* toggle LED2 each 500ms */
//        led1_open(B);
//        vTaskDelay(500);
//				led1_close(B);
//				vTaskDelay(500);
//    }
//}上列代码是使用FreeRTOS使LED亮灭的基本测试程序
 
  //   nvic_irq_enable(TIMER6_IRQn,1,1);//timer6基本定时器中断优先级设置
//    timer_configuration(6);//timer6基本定时器初始化及使能中断，水弹发射50ms定时
 
 
 
 
 //串口-电机发送任务块创建
//void Usart_Send_Task(void * pvParameters)//发送数据的函数
//{
//	while(1)
//	{
//		vTaskDelay(2);//2ms执行一次。
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


//    usart_ubt_init(0,115200U);//GPIO转usart0初始化
//    usart_ubt_init(3,115200U);//GPIO转usart3初始化
// 		usart_ubt_init(2,115200U);//GPIO转usart2初始化
// 		usart_ubt_init(1,115200U);//GPIO转usart1初始化
// 		usart_ubt_init(4,115200U);//GPIO转usart4初始化
// 		usart_ubt_init(5,9600U);//用于水弹发射

//
////    nvic_irq_enable(USART0_IRQn, 0, 0);//usart中断优先级设置，信号的接收在中断中进行
//    usart_interrupt_enable(USART0, USART_INT_RBNE);//usart0接收数据中断使能







