//led灯头文件
#ifndef _led_h
#define _led_h

#include "gd32f4xx.h"

void led_init(void);

#define R 0
#define G 1
#define B 2

//led1亮灭
void led1_open(unsigned char led_colour);
void led1_close(unsigned char led_colour);
void led1_toggle(unsigned char led_colour);
//led2亮灭
void led2_open(unsigned char led_colour);
void led2_close(unsigned char led_colour);
void led2_toggle(unsigned char led_colour);
//延迟
void delay_x_ms(uint32_t x);//根据案例改写,x就是延时多少毫秒。
void delay_start(void);//根据案例改写,放在中断Timer6中，中断设置为1MS。
#endif
