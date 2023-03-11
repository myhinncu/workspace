
#include "gd32f4xx_it.h"
#include "bluetooth_protocol.h"
#include "systick.h"
#include "led.h"
#include "gd32f4xx_usart.h"

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
void USART0_IRQHandler(void)//空闲中断
{
	char x;//数组清零
	uint32_t data;
	//usart_interrupt_flag_clear(USART0,USART_INT_FLAG_IDLE);
	data=USART_STAT0(USART0);
	data=USART_DATA(USART0);
	dma_channel_disable(DMA1, DMA_CH2);
	if((bluetooth_rx_buf[0]==0XAA)&&(bluetooth_rx_buf[8] == 0X0D)&&(bluetooth_rx_buf[9] == 0X0A))//
	{
			read_signal();
			signal_process(motorusart);
			for(x=0;x<=9;x++)
			{
				bluetooth_rx_buf[x]=0X00;
			}
			Bluetooth_RX=0;
	}
	dma_interrupt_flag_clear(DMA1,DMA_CH2,DMA_INT_FLAG_FTF);
	dma_transfer_number_config(DMA1,DMA_CH2, 10);
	dma_memory_address_config(DMA1,DMA_CH2,DMA_MEMORY_0,(uint32_t)bluetooth_rx_buf);
	dma_channel_enable(DMA1, DMA_CH2);
	
	if(Bluetooth_RX>=10)//确保数组不会溢出
		Bluetooth_RX=0;			
	usart_interrupt_flag_clear(USART0,USART_INT_FLAG_IDLE);
}


void TIMER6_IRQHandler(void)//用作获取准确1ms定时,1ms中断一次。发射水弹用
{
	delay_start();
	timer_interrupt_flag_clear(TIMER6,TIMER_INT_UP);
}
//用作获取准确1ms定时,1ms中断一次。


//void SysTick_Handler(void)由于FreeRTOS，systick函数被注释。
//{
//    delay_decrement();
//}


