
#ifndef _SERIAL_H
#define _SERIAL_H
#include "stm32f4xx_conf.h"

#define USARTX 				USART1
#define USARTX_IRQn 		USART1_IRQn
#define USARTX_IRQHandler 	USART1_IRQHandler


#define RX_BUFFER_SIZE 128
#define READ_LINE_SIZE 50

#ifndef FORCE_INLINE
#define FORCE_INLINE inline __attribute__((always_inline))
#endif

extern uint16_t serial_available(void);
uint8_t serial_read_char(void);
extern void serial_write_char(char ch);
void serial_write_string(char *s);
void serial_init(uint32_t baud);
void serial_write_int(int num);
char* serial_read_line(void);
#endif
