/*
* @Author: abing
* @Date:   2017-01-10 21:26:09
* @Last Modified by:   abing
* @Last Modified time: 2017-01-12 16:51:31
*/
#include "serial.h"

typedef struct ring_buffer {
	uint8_t buffer[RX_BUFFER_SIZE];
	uint16_t head;
	uint16_t tail;
} ring_buffer;
ring_buffer rx_buffer = {{0}, 0, 0};

void serial_init(uint32_t baud)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	USART_InitTypeDef USART_InitStructure;
	NVIC_InitTypeDef NVIC_InitStructure;

	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);

	GPIO_PinAFConfig(GPIOA, GPIO_PinSource9, GPIO_AF_USART1);
	GPIO_PinAFConfig(GPIOA, GPIO_PinSource10, GPIO_AF_USART1);

	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_9 | GPIO_Pin_10;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
	GPIO_Init(GPIOA, &GPIO_InitStructure);

	USART_InitStructure.USART_BaudRate = baud;
	USART_InitStructure.USART_WordLength = USART_WordLength_8b;
	USART_InitStructure.USART_StopBits = USART_StopBits_1;
	USART_InitStructure.USART_Parity = USART_Parity_No;
	USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
	USART_Init(USARTX, &USART_InitStructure);

	//NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);

	NVIC_InitStructure.NVIC_IRQChannel = USARTX_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 3;
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStructure);

	USART_Cmd(USARTX, ENABLE);
	USART_ITConfig(USARTX, USART_IT_RXNE, ENABLE);
}
FORCE_INLINE uint16_t serial_available(void)
{
	return (uint16_t)(RX_BUFFER_SIZE + rx_buffer.head - rx_buffer.tail) % RX_BUFFER_SIZE;
}

uint8_t serial_read_char(void)
{
#ifdef SERIAL_READ_CHECK
	if (rx_buffer.head == rx_buffer.tail) {
		return 0;
	} else {
#endif
		uint8_t c = rx_buffer.buffer[rx_buffer.tail];
		rx_buffer.tail = (uint16_t)(rx_buffer.tail + 1) % RX_BUFFER_SIZE;
		return c;
#ifdef SERIAL_READ_CHECK
	}
#endif
}

char* serial_read_line(void)
{
	static char res[READ_LINE_SIZE] CCM_RAM;
	int i = 0;
	char c;
	while (1) {
		if (serial_available()) {
			c = serial_read_char();
			if (c == '\n' || i >= READ_LINE_SIZE - 1) {
				res[i] = 0;
				return res;
			}
			res[i++] = c;
		}
	}
}

FORCE_INLINE void serial_write_char(char ch)
{
	while ((USARTX->SR & 0X40) == 0);
	USARTX->DR = (uint8_t) ch;
}

void serial_write_string(char *s)
{
	while (*s) {
		serial_write_char(*s++);
	}
}

void serial_write_int(int n)
{
	char num[20];
	int i = 0;
	if (n < 0) {
		n = -n;
		serial_write_char('-');
	}
	for (i = 0; n != 0; i++) {
		num[i] = n % 10;
		n = n / 10;
	}
	while (i--) {
		serial_write_char(num[i] + '0');
	}
}

static void store_char(uint8_t c)
{
	uint16_t i = (uint16_t)(rx_buffer.head + 1) % RX_BUFFER_SIZE;

	if (i != rx_buffer.tail) {
		rx_buffer.buffer[rx_buffer.head] = c;
		rx_buffer.head = i;
	}
}


void USARTX_IRQHandler(void)
{
	if (USART_GetITStatus(USARTX, USART_IT_RXNE) != RESET) {
		uint8_t res = USART_ReceiveData(USARTX);
		store_char(res);
	}
}
