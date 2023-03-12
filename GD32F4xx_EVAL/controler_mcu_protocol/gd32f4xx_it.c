
#include "gd32f4xx_it.h"
#include "bluetooth_protocol.h"
#include "systick.h"
#include "led.h"

void NMI_Handler(void)
{
}

void HardFault_Handler(void)
{
    /* if Hard Fault exception occurs, go to infinite loop */
    while(1);
}

void MemManage_Handler(void)
{
    /* if Memory Manage exception occurs, go to infinite loop */
    while(1);
}

void BusFault_Handler(void)
{
    /* if Bus Fault exception occurs, go to infinite loop */
    while(1);
}

void UsageFault_Handler(void)
{
    /* if Usage Fault exception occurs, go to infinite loop */
    while(1);
}

//void SVC_Handler(void)由于FreeRTOS，函数被注释。
//{
//}由于FreeRTOS，函数被注释。

void DebugMon_Handler(void)
{
}

//void PendSV_Handler(void)由于FreeRTOS，函数被注释。
//{
//}由于FreeRTOS，函数被注释。

//FreeRTOS的中断函数，用来接收数据，只接收和赋值，不进行判断
void USART0_IRQHandler(void)
{
//	char x;//数组清零
//	
//	bluetooth_rx_buf[Bluetooth_RX]=usart_data_receive(USART0);//进入中断就接收
//	Bluetooth_RX++;
//	if((bluetooth_rx_buf[0]!=0XAA)&&(Bluetooth_RX>=9))//保证第一个元素必须是0XAA
//		Bluetooth_RX=0;
//	
//	if((bluetooth_rx_buf[8] == 0X0D)&&(bluetooth_rx_buf[9] == 0X0A))//第一个不是0XAA，这个IF不会执行。
//	{
//			read_signal();//只要来一帧信号，就读取进来
//			for(x=0;x<=9;x++)
//			{
//				bluetooth_rx_buf[x]=0X00;
//			}
//			Bluetooth_RX=0;
//	}
//	
//	if(Bluetooth_RX>=10)//确保数组不会溢出
//		Bluetooth_RX=0;			
//		usart_interrupt_flag_clear(USART0,USART_INT_FLAG_RBNE);
}//FreeRTOS的中断函数，用来接收数据，只接收和赋值，不进行判断。


void TIMER6_IRQHandler(void)//用作获取准确1ms定时,1ms中断一次。发射水弹用
{
	delay_start();
	timer_interrupt_flag_clear(TIMER6,TIMER_INT_UP);
}
//用作获取准确1ms定时,1ms中断一次。

void DMA1_Channel2_IRQHandler(void)
{
	read_signal();
}




//void SysTick_Handler(void)由于FreeRTOS，systick函数被注释。
//{
//    delay_decrement();
//}


