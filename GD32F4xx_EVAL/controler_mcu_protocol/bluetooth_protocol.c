#include "bluetooth_protocol.h"
#include "ubt_motor.h"
#include "led.h"

unsigned char bluetooth_rx_buf[10];//用作中断中暂时接收一帧数据
char Bluetooth_RX;//和上面数组配套使用，数组的元素号
enum move_mode {RUN_Forward=1, RUN_Back, TURN_Right, TURN_Left, SIDESWAY_left,SIDESWAY_right,STOP};//行走模式
int move_mode = STOP;//初始的行走模式是stop

//char last_move_mode;//上一次行走模式，暂时没有使用到
bluetooth_struct bluetooth_signal;

void read_signal(void)//读取信号。
{
	bluetooth_signal.Key_Hval=bluetooth_rx_buf[1];//控制前进后退
	bluetooth_signal.Key_Lval=bluetooth_rx_buf[2];//水弹
	//bluetooth_signal.L_x_val=bluetooth_rx_buf[3];
	//bluetooth_signal.L_y_val=bluetooth_rx_buf[4];
	//bluetooth_signal.R_x_val=bluetooth_rx_buf[5];
	//bluetooth_signal.R_y_val=bluetooth_rx_buf[6];
}

void signal_process(int motorcom)//motorcom代表端口1。
{
	//根据Key_Hval值判断行走模式
	if(bluetooth_signal.Key_Hval == 0X10)//0x10是前进，下面类似
    {
       move_mode=RUN_Forward;
    }
    else if(bluetooth_signal.Key_Hval == 0x40)
    {
      move_mode=RUN_Back;
    }
    else if(bluetooth_signal.Key_Hval == 0x80)
    {
      move_mode=TURN_Left;
    }
    else if (bluetooth_signal.Key_Hval == 0x20)
    {
       move_mode=TURN_Right;
    }
		else if(bluetooth_signal.Key_Lval == 0x10)
		{
			fire_control(motorcom+4,low);
		}
		else if(bluetooth_signal.Key_Lval == 0x20)
		{
			fire_control(motorcom+4,fast);
		}
		else if(bluetooth_signal.Key_Lval == 0x40)
		{
			fire_control(motorcom+4,close);
		}
		else
		{
			move_mode=STOP;
		}
		motor_stoppattern_integrate(motorcom,1);//设置电机停止模式。1代表惯性停止
		if(move_mode==STOP)
		{
			motor_stop_integrate(motorcom);//如果停止就四个轮子都停下来
		}
		switch(move_mode)//判断行走模式，若为stop，则switch语句case都不会发生
		{
			case RUN_Forward://如果是runforward，则向前行走，下面的case都是一个意思
						motor_run_integrate(motorcom,!rotate_direction,sudu);//sudu参数可以改变，是个宏定义，需要改动在ubt_motor.h文件中改动，代表行走速度。
			break;
			case 	RUN_Back:
						motor_run_integrate(motorcom,rotate_direction,sudu);
			break;
			case TURN_Left:
						motor_turn_integrate(motorcom,rotate_direction,sudu);
			break;
			case TURN_Right:
						motor_turn_integrate(motorcom,!rotate_direction,sudu);
			break;
			case SIDESWAY_right:
						motor_sidesway_integrate(motorcom,rotate_direction,sudu);
			break;
			case SIDESWAY_left:
						motor_sidesway_integrate(motorcom,!rotate_direction,sudu);
			break;
		}
}


//else if(bluetooth_signal.Key_Lval == 0x20)左右行走
//{
//	move_mode=SIDESWAY_right;
//}
//else if(bluetooth_signal.Key_Lval == 0x10)
//{
//	move_mode=SIDESWAY_left;
//}左右行走

		
