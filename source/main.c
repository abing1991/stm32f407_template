/*
* @Author: abing
* @Date:   2017-01-03 22:22:52
* @Last Modified by:   abing
* @Last Modified time: 2017-01-12 20:50:35
*/
#include "bsp.h"
void led_blink(void);

int main(void)
{
	//NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);
	serial_init(115200);
	led_init();

	for (;;) {
		led_blink();
	}
}

void delay(uint32_t n)
{
	while (n--);
}

void led_blink(void)
{
	while (1) {
		if (serial_available()) {
			serial_write_char(serial_read_char());
		}
		serial_write_string("led flash!\n");
		led_on(LED1);
		delay(0xFFFFFF);
		led_off(LED1);
		delay(0xFFFFFF);
	}
}
