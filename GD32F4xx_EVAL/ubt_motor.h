/*
存储控制电机协议
*/
#ifndef _ubt_motor_h
#define _ubt_motor_h

#include "stdint.h"
#include "gd32f4xx.h"
#include "usart_urbantoo.h"
#include "systick.h"
#include "led.h"
#define rotate_direction 0//电机转动方向，不需要改动
#define sudu 0x50 //行走速度，可以改为0x01-0x64任意一个数

//电机串口协议
//static char turn_forward[12] = {0xEB,0xA5,0xFF,0x00,0x06,0xFF,0xFF,0x02,0x03,0x0E,0x00,0x16}; //电机正转
//static char turn_speed[12] = {0xEB,0xA5,0xFF,0x00,0x07,0xFF,0xFF,0x02,0x03,0x07,0x00,0x24};   //转速
//static char motor_power[12] = {0xEB,0xA5,0xFF,0x00,0x06,0xFF,0xFF,0x02,0x03,0x06,0x04,0x72};       //电机功率

//static char motor_start[13] = {0xEB,0xA5,0xFF,0x00,0x07,0xFF,0xFF,0x02,0x02,0x12,0x01,0x00,(0xff+0x07+0xff+0xff+0x02+0x02+0x12+0x01)&0xff};         //电机启动  

//static char motor_stop[12] = {0xEB,0xA5,0xFF,0x00,0x06,0xFF,0xFF,0x02,0x02,0x12,0x00,0x19};  //

/*
struct chat//与电机通讯协议结构体
{
    0    F1;//帧头1
    1 F2;//帧头2
    2 type;//类型
    3 length_H;//长度高字节（ID+命令+data的字节数）
    4 length_L;//长度低字节
    5 ID_H;//从机上电后默认为0，由主机分配。
    6 ID_L;//分为两级ID，高字节为第一级ID，低字节为第二级ID。通用ID:0xFF 0xFF
    7 command;//命令 0x00查询设备，0x01设置ID ,0x02执行具体指令
    8 data_fun;//数据功能:   由<命令>字段决定这部分的内容，0x02读取电机指令 0x03往电机内写指令
    9 data_address;//数据地址
    10 data_para1;//参数1
    11 data_para2;//参数2
    12 data3
    13 data4
    14 cs;//(类型+长度+ID+命令+数据)&0xFF
};*/
//主机发送和主机接收协议
static char chat_t[15]={0xEB,0xA5,0xFF,0x00,0x00,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
static char chat_r[15]={0xEB,0xA5,0xFF,0x00,0x00,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

//chat补完，计算length和cs字节
void chat_patch(void);

//查询设备
void chat_device(int com);

//电机启动
void motor_start(int motorcom);
//电机停止
void motor_stop(int motorcom);
//电机停止封装
void motor_stop_integrate(int motorcom);
//电机左右横移运行封装
void motor_sidesway_integrate(int motorcom,char dir,char speed);
//电机前进后退运行封装
void motor_run_integrate(int motorcom,char dir,char speed);
//电机左右转向运行封装
void motor_turn_integrate(int motorcom,char dir,char speed);
/*
电机功率
motorcom:电机所在串口号；
power：功率0~100，0x00~0x64
*/
void motor_power(int motorcom,char power);
/*
电机速度
motorcom:电机所在串口号；
speed：转速0~100，0x00~0x64
*/
void motor_speed(int motorcom,char speed);
/*
电机停止方式
pattern:0=立即停止；1=惯性停止
*/
void motor_stop_pattern(int motorcom,char pattern);
/*
电机停止方式，把上面的函数封装起来，四个在一个函数里面一起改。
pattern:0=立即停止；1=惯性停止
*/
void motor_stoppattern_integrate(int motorcom,char pattern);
/*
电机转动方向：顺时针为正
dir:0=正；1=负
*/
void motor_direction(int motorcom,char dir);
/*
电机转动圈数
num：圈数0~9999
num1~num4:从高位到低位
*/
void motor_numcircle(int motorcom,char num1,char num2,char num3,char num4);
/*
电机转动角度
angle:角度：0~9999
*/
void motor_angle(int motorcom,char angle1,char angle2,char angle3,char angle4);
/*
电机转动时间
time:时间：0~9999
时间的精度为小数点后两位，实际发送的参数为时间扩大100倍。例：66.36秒则发送6636
*/
void motor_time(int motorcom,char time1,char time2,char time3,char time4);

/*
水弹发射协议
*firecom:水弹的串口号
*velocity：水弹状态--close关闭，low低速，fast高速
*串口波特率9600U
	接收0x94
	接收0x81，为关闭；
	接收0x94
	接收0x82，为低速
	接收0x94
	接收0x84，为高速	
*/
#define close 0x81
#define low   0x82
#define fast  0x84
void fire_control(int firecom,char velocity);



#endif

