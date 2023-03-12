
#include "initialization.h"
#include "bluetooth_protocol.h"

void timer_configuration(char com)//timer定时器配置，启用timer_com。
{
    timer_parameter_struct timer_initpara;
		timer_struct_para_init(&timer_initpara);
		timer_deinit(timer_num[com]);
    rcu_periph_clock_enable(RCU_timer_num[com]);
	
		rcu_timer_clock_prescaler_config(RCU_TIMER_PSC_MUL4);

     //TIMER_com configuration 
    timer_initpara.prescaler         = 199;//
    timer_initpara.alignedmode       = TIMER_COUNTER_EDGE;
    timer_initpara.counterdirection  = TIMER_COUNTER_UP;
    timer_initpara.period            = 999;//0-999计数1000次
    timer_initpara.clockdivision     = TIMER_CKDIV_DIV1;
    timer_initpara.repetitioncounter = 0;
    timer_init(timer_num[com],&timer_initpara);

		timer_auto_reload_shadow_enable(timer_num[com]);//2023/3/1
    // clear channel com interrupt bit 
    timer_interrupt_flag_clear(timer_num[com],TIMER_INT_UP);
     //channel com interrupt enable 
    timer_interrupt_enable(timer_num[com],TIMER_INT_UP);

     //TIMER_com counter enable 
    timer_enable(timer_num[com]);
}

void dma_configuration(void)
{
	/* deinitialize DMA1 channel2 (USART0 RX) */
		dma_single_data_parameter_struct dma_init_struct;
	  rcu_periph_clock_enable(RCU_DMA1);
    dma_deinit(DMA1, DMA_CH2);
    dma_init_struct.direction = DMA_PERIPH_TO_MEMORY;
    dma_init_struct.memory0_addr = (uint32_t)bluetooth_rx_buf;
    dma_init_struct.memory_inc = DMA_MEMORY_INCREASE_ENABLE;
    dma_init_struct.number = 10;
    dma_init_struct.periph_addr = (uint32_t)&USART_DATA(USART0);
    dma_init_struct.periph_inc = DMA_PERIPH_INCREASE_DISABLE;
    dma_init_struct.periph_memory_width = DMA_PERIPH_WIDTH_8BIT;
    dma_init_struct.priority = DMA_PRIORITY_ULTRA_HIGH;
    dma_single_data_mode_init(DMA1, DMA_CH2, &dma_init_struct);

    /* configure DMA mode */
    dma_circulation_disable(DMA1, DMA_CH2);
    dma_channel_subperipheral_select(DMA1, DMA_CH2, DMA_SUBPERI4);
    /* enable DMA1 channel2 transfer complete interrupt */
    dma_interrupt_enable(DMA1, DMA_CH2, DMA_CHXCTL_FTFIE);
    /* enable DMA1 channel2 */
    dma_channel_enable(DMA1, DMA_CH2);
}
