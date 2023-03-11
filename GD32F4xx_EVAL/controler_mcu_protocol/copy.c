
//#include "gd32f4xx.h"
//#include <stdio.h>
//#include "gd32f450i_eval.h"
//#include "led.h"
//#include "bluetooth_protocol.h"
//#include "initialization.h"
//#include "usart_urbantoo.h"

///*!
//    \brief      main function
//    \param[in]  none
//    \param[out] none
//    \retval     none
//*/

//int main(void)
//{
//    /* USART interrupt configuration */
//    nvic_irq_enable(USART0_IRQn, 0, 0);//usart中断初始化
//    /* configure COM0 */
//   // gd_eval_com_init(EVAL_COM0);//GPIO转串口初始化
//		usart_ubt_init(0);
//		usart_interrupt_enable(USART0, USART_INT_RBNE);
//		nvic_irq_enable(TIMER2_IRQn,1,1);//定时器中断优先级设置
//		timer_configuration(2);//定时器初始化及使能中断
//		led_init();
//		led1_open(R);
//	 while(1)
//	 {
//		 ;
//	 }
//		 return 0;
//}


///* retarget the C library printf function to the USART */
//int fputc(int ch, FILE *f)
//{
//    usart_data_transmit(EVAL_COM0, (uint8_t)ch);
//    while(RESET == usart_flag_get(EVAL_COM0, USART_FLAG_TBE));
//    return ch;
//}
