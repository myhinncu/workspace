/*����ң������Ƭ�����͵�����*/
#ifndef _bluetooth_protocal_h
#define _bluetooth_protocal_h

#include "gd32f4xx.h"
#include <stdio.h>

extern unsigned char bluetooth_rx_buf[10];
extern char Bluetooth_RX;

typedef struct 
{
 unsigned char Key_Hval;
 unsigned char Key_Lval;
 //unsigned char L_x_val; ҡ�ˣ���ʱ����
 //unsigned char L_y_val;
 //unsigned char R_x_val;
 //unsigned char R_y_val;
}bluetooth_struct;

extern bluetooth_struct bluetooth_signal;

void read_signal(void);//��ȡ�ź�

void signal_process(int motorcom);//�����źš�

#endif

