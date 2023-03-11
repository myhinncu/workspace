/*

*/
#ifndef _usart_urbantoo_h

#define _usart_urbantoo_h

#include "stdint.h"
#include "gd32f4xx.h"

//UBT电路板USART端口定义
//第5个串口rcu使能要加上RCU_GPIOD
static rcu_periph_enum usart_gpio_clk[8] = {RCU_GPIOA,RCU_GPIOA,RCU_GPIOB,RCU_GPIOA,RCU_GPIOC,RCU_GPIOG,RCU_GPIOE,RCU_GPIOE};
static rcu_periph_enum usart_clk[8]={ RCU_USART0,RCU_USART1,RCU_USART2,RCU_UART3,RCU_UART4,RCU_USART5,RCU_UART6,RCU_UART7};

static uint32_t usart_TX_gpio[8] = {GPIOA,GPIOA,GPIOB,GPIOA,GPIOC,GPIOG,GPIOE,GPIOE};
static uint32_t usart_RX_gpio[8] = {GPIOA,GPIOA,GPIOB,GPIOA,GPIOD,GPIOG,GPIOE,GPIOE};

static uint32_t usart_TX_PIN[8] = {GPIO_PIN_9,GPIO_PIN_2,GPIO_PIN_10,GPIO_PIN_0,GPIO_PIN_12,GPIO_PIN_14,GPIO_PIN_8,GPIO_PIN_1};
static uint32_t usart_RX_PIN[8] = {GPIO_PIN_10,GPIO_PIN_3,GPIO_PIN_11,GPIO_PIN_1,GPIO_PIN_2,GPIO_PIN_9,GPIO_PIN_7,GPIO_PIN_0};

static uint32_t usart_num[8]={USART0,USART1,USART2,UART3,UART4,USART5,UART6,UART7};

//串口初始化
void usart_ubt_init(int com,unsigned int baudrate);

//发送一个数据
void send_char(int com,char ch);

//USART发送数据
void usart_ubt_trans(int com,char *j, int len);

//接收一个数据
char receive_char(int com);

//接收数据
void usart_ubt_receive(int com);

#endif
