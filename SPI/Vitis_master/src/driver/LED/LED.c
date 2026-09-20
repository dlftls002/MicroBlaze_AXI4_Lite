#include "LED.h"

void Led_Init() {
	// led connect
	GPIO_SetMode(LED_PORT,
			LED_PIN_0 | LED_PIN_1 | LED_PIN_2 | LED_PIN_3 | LED_PIN_4
					| LED_PIN_5 | LED_PIN_6 | LED_PIN_7, OUTPUT);
}

void LED_OnOff(uint32_t LED_PIN, int OnOff) {
	GPIO_WritePin(LED_PORT, LED_PIN, OnOff);
}

void LED_AllOff() {
	LED_OnOff(LED_PIN_0 | LED_PIN_1 | LED_PIN_2 | LED_PIN_3 |
	LED_PIN_4 | LED_PIN_5 | LED_PIN_6 | LED_PIN_7, RESET);
}

