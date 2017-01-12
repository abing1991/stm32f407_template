/*
* @Author: abing
* @Date:   2017-01-10 21:26:09
* @Last Modified by:   abing
* @Last Modified time: 2017-01-11 21:42:00
*/
#include "led.h"

void led_on(uint16_t pin)
{
	GPIO_ResetBits(LED_PORT, pin);
}

void led_off(uint16_t pin)
{
	GPIO_SetBits(LED_PORT, pin);
}

void led_init()
{
	GPIO_InitTypeDef  GPIO_InitStructure;
	/* Enable the GPIO_LED Clock */
	RCC_AHB1PeriphClockCmd( LED_GPIO_CLK, ENABLE);

	GPIO_InitStructure.GPIO_Pin = LED1 | LED2;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_Init(LED_PORT, &GPIO_InitStructure);

	led_off(LED1 | LED2);
}
