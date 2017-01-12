#ifndef _LED_H
#define _LED_H
#include "stm32f4xx_conf.h"
#define LED1 GPIO_Pin_4
#define LED2 GPIO_Pin_5
#define LED_PORT GPIOA
#define LED_GPIO_CLK RCC_AHB1Periph_GPIOA
void led_init(void);
void led_on(uint16_t pin);
void led_off(uint16_t pin);

#endif
