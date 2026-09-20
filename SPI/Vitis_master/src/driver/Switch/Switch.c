#include "Switch.h"

void Switch_Init()
{
	GPIO_SetMode(GPIOD,
			SW_PIN_0 | SW_PIN_1 | SW_PIN_2 | SW_PIN_3 | SW_PIN_4
					| SW_PIN_5 | SW_PIN_6 | SW_PIN_7, INPUT);
}

uint8_t Switch_Read() // Read 8 bits at once
{
    return (uint8_t)(GPIO_ReadPort(GPIOD) & 0xFF);
}
