/*
串口通信函数
*/
#include "usart_urbantoo.h"




/*
串口初始化
com:0~7USART口
*/
void usart_ubt_init(int com,unsigned int baudrate)
{
    
    //gpio时钟使能
    rcu_periph_clock_enable(usart_gpio_clk[com]);
    if (com == 4)
    {
        rcu_periph_clock_enable(RCU_GPIOD);
    }
    //usart时钟使能
    rcu_periph_clock_enable(usart_clk[com]);

    /* connect port to USARTx_Tx and RX*/
    if (com == 0|| com ==1 || com == 2)
    {
    gpio_af_set(usart_TX_gpio[com], GPIO_AF_7, usart_TX_PIN[com]);
    gpio_af_set(usart_RX_gpio[com], GPIO_AF_7, usart_RX_PIN[com]);
    gpio_af_set(usart_RX_gpio[com], GPIO_AF_7, usart_RX_PIN[com]);
    }
    else if(com== 3|| com ==4 || com ==5 ||com ==6||com ==7)
    {
    gpio_af_set(usart_TX_gpio[com], GPIO_AF_8, usart_TX_PIN[com]);
    gpio_af_set(usart_RX_gpio[com], GPIO_AF_8, usart_RX_PIN[com]);
    gpio_af_set(usart_RX_gpio[com], GPIO_AF_8, usart_RX_PIN[com]);
    }
    
    //设置gpio口模式
    gpio_mode_set(usart_TX_gpio[com], GPIO_MODE_AF, GPIO_PUPD_PULLUP,usart_TX_PIN[com]);
    gpio_output_options_set(usart_TX_gpio[com], GPIO_OTYPE_PP, GPIO_OSPEED_50MHZ,usart_TX_PIN[com]);

    gpio_mode_set(usart_RX_gpio[com], GPIO_MODE_AF, GPIO_PUPD_PULLUP,usart_RX_PIN[com]);
    gpio_output_options_set(usart_RX_gpio[com], GPIO_OTYPE_PP, GPIO_OSPEED_50MHZ,usart_RX_PIN[com]);

    //设置USART参数··
    usart_deinit(usart_num[com]);//复位外设USART
    usart_baudrate_set(usart_num[com],baudrate);//配置USART波特率
    usart_receive_config(usart_num[com], USART_RECEIVE_ENABLE);//USART接收器配置 使能
    usart_transmit_config(usart_num[com], USART_TRANSMIT_ENABLE);//USART发送器配置 使能
    usart_enable(usart_num[com]);//使能USART

}

/*
*USART发送字节
*com:usart序号0~7
*/
void send_char(int com,char ch)
{
   while(RESET == usart_flag_get(usart_num[com], USART_FLAG_TBE)){};//等待“发送数据缓冲区空标志位”清0
    usart_data_transmit(usart_num[com],ch);
		//usart_flag_get(usart_num[com], USART_FLAG_TC); 0xAA
}

/*
*USART发送数据
*
*/
void usart_ubt_trans(int com,char *j, int len)
{
    while (len--)
    {
        send_char(com,*j++);
    }
}


