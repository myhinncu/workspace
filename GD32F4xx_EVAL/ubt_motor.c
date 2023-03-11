
#include "ubt_motor.h"
#include "gd32f4xx.h"
#include "initialization.h"

//chat补完，计算length和cs字节
void chat_patch(void)
{
    chat_t[3]=0x00;
    chat_t[4]=0x09;
    chat_t[14]=(chat_t[2]+chat_t[3]+chat_t[4]\
    +chat_t[5]+chat_t[6]+chat_t[7]+\
    chat_t[9]+chat_t[8]+chat_t[10]+chat_t[11]+chat_t[12]+chat_t[13]) & 0xff;

}

//电机启动
void motor_start(int motorcom)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x12;
    chat_t[10]=0x01;
    chat_t[11]=0x00;
    chat_t[12]=0x00;
    chat_t[13]=0x00;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}

//电机停止
void motor_stop(int motorcom)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x12;
    chat_t[10]=0x00;
    chat_t[11]=0x00;
    chat_t[12]=0x00;
    chat_t[13]=0x00;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}
//电机停止封装，四个电机一起停止
void motor_stop_integrate(int motorcom)//四个电机同时停转
{
	motor_stop(motorcom);//usart1控制的电机停止转动，因为motorcom设置为1
	motor_stop(motorcom+1);//usart2控制的电机停止转动，因为motorcom设置为1
	motor_stop(motorcom+2);//usart3控制的电机停止转动，因为motorcom设置为1
	motor_stop(motorcom+3);//usart4控制的电机停止转动，因为motorcom设置为1
}
//把四个电机的停止模式统一起来，因为停止模式一般是一样的。
void motor_stoppattern_integrate(int motorcom,char pattern)
{
	motor_stop_pattern(motorcom,pattern);
	motor_stop_pattern(motorcom+1,pattern);
	motor_stop_pattern(motorcom+2,pattern);
	motor_stop_pattern(motorcom+3,pattern);
}
//小车左右横移函数
void motor_sidesway_integrate(int motorcom,char dir,char speed)//同时设置四个电机的速度，并且启动。移动效果是左右横向移动
{
		motor_speed(motorcom,speed);
		motor_direction(motorcom,dir);
		motor_start(motorcom);
		motor_speed(motorcom+1,speed);
		motor_direction(motorcom+1,!dir);
		motor_start(motorcom+1);
		motor_speed(motorcom+2,speed);
		motor_direction(motorcom+2,dir);
		motor_start(motorcom+2);
		motor_speed(motorcom+3,speed);
		motor_direction(motorcom+3,!dir);
		motor_start(motorcom+3);
		//motor_angle 
		//motor_numcircle
		//motor_time
		//motor_power 
	  //motor_speed(motorcom,0x60);
}
//小车前进后退函数
void motor_run_integrate(int motorcom,char dir,char speed)//同时设置四个电机的速度，并且启动。移动效果是前进和后退
{
		motor_speed(motorcom,speed);//usart1控制的电机设置速度
		motor_direction(motorcom,dir);//usart1控制的电机设置转动方向
		motor_start(motorcom);//usart1控制的电机启动
		motor_speed(motorcom+1,speed);//usart2控制的电机设置速度
		motor_direction(motorcom+1,dir);//usart2控制的电机设置转动方向
		motor_start(motorcom+1);//usart2控制的电机启动
		motor_speed(motorcom+2,speed);//usart3控制的电机设置速度
		motor_direction(motorcom+2,!dir);//usart3控制的电机设置转动方向
		motor_start(motorcom+2);//usart3控制的电机启动
		motor_speed(motorcom+3,speed);//usart4控制的电机设置速度
		motor_direction(motorcom+3,!dir);//usart4控制的电机设置转动方向
		motor_start(motorcom+3);//usart4控制的电机启动
		//motor_angle 
		//motor_numcircle
		//motor_time
		//motor_power 
	  //motor_speed(motorcom,0x60);
}
//小车转向函数
void motor_turn_integrate(int motorcom,char dir,char speed)//同时设置四个电机的速度，并且启动。移动效果是左右转向
{
		motor_speed(motorcom,speed);
		motor_direction(motorcom,dir);
		motor_start(motorcom);
		motor_speed(motorcom+1,speed);
		motor_direction(motorcom+1,dir);
		motor_start(motorcom+1);
		motor_speed(motorcom+2,speed);
		motor_direction(motorcom+2,dir);
		motor_start(motorcom+2);
		motor_speed(motorcom+3,speed);
		motor_direction(motorcom+3,dir);
		motor_start(motorcom+3);
		//motor_angle 
		//motor_numcircle
		//motor_time
		//motor_power 
	  //motor_speed(motorcom,0x60);
}


/*
电机功率
*/
void motor_power(int motorcom,char power)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x06;
    chat_t[10]=power;//power 0~100
    chat_t[11]=0x00;
    chat_t[12]=0x00;
    chat_t[13]=0x00;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}

//电机转速
void motor_speed(int motorcom,char speed)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x07;
    chat_t[10]=0x00;//speed 0~100
    chat_t[11]=speed;
    chat_t[12]=0x00;
    chat_t[13]=0x00;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}

//电机停止方式
void motor_stop_pattern(int motorcom,char pattern)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x0D;
    chat_t[10]=pattern;//speed 0~100
    chat_t[11]=0x00;
    chat_t[12]=0x00;
    chat_t[13]=0x00;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}

//电机转动方向：顺时针为正
void motor_direction(int motorcom,char dir)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x0E;
    chat_t[10]=dir;//speed 0~100
    chat_t[11]=0x00;
    chat_t[12]=0x00;
    chat_t[13]=0x00;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}

//电机转动圈数
void motor_numcircle(int motorcom,char num1,char num2,char num3,char num4)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x0F;
    chat_t[10]=num1;
    chat_t[11]=num2;
    chat_t[12]=num3;
    chat_t[13]=num4;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}

//电机转动角度
void motor_angle(int motorcom,char angle1,char angle2,char angle3,char angle4)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x10;
    chat_t[10]=angle1;//angle 0~100
    chat_t[11]=angle2;
    chat_t[12]=angle3;
    chat_t[13]=angle4;

    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}

//电机转动时间
void motor_time(int motorcom,char time1,char time2,char time3,char time4)
{
    chat_t[7]=0x02;
    chat_t[8]=0x03;//write data
    chat_t[9]=0x11;
    chat_t[10]=time1;//speed 0~100
    chat_t[11]=time2;
    chat_t[12]=time3;
    chat_t[13]=time4;
    chat_patch();

    usart_ubt_trans(motorcom,chat_t,15);
}


//查询设备
void chat_device(int com)
{
    char device[10]={0xEB,0XA5,0XFF,0X00,0X04,0XFF,0XFF,0X00,0X00,(0XFF+0X00+0X04+0XFF+0XFF+0X00+0X00)&0XFF};

    usart_ubt_trans(com,device,10);
  

}


//接收数据
void usart_moto_receive(int com)
{
	char temp;int i;
    while (1)
    {
        temp=usart_data_receive(usart_num[com]);
        if (temp==chat_r[0])
        {
            i=0;
        }
        chat_r[i]=temp;
        
    }
}

//水弹发射
void fire_control(int firecom,char velocity)
{	
		usart_disable(usart_num[0]);
		timer_enable(timer_num[6]);
    send_char(firecom,0x94);
    while(timer_flag_get(TIMER6,TIMER_FLAG_UP)==0);//延迟55ms
    send_char(firecom,velocity);
		timer_flag_clear(TIMER6,TIMER_FLAG_UP);
		//timer_disable(timer_num[6]);
		usart_enable(usart_num[0]);
}

//void motor_stoppattern_integrate(int motorcom,char pattern)//把四个电机的停止模式统一起来，因为停止模式肯定都是一样的。
//{
//	motor_stop_pattern(motorcom,pattern);
//	motor_stop_pattern(motorcom+1,pattern);
//	motor_stop_pattern(motorcom+2,pattern);
//	motor_stop_pattern(motorcom+3,pattern);
//}
