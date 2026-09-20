
#ifndef SRC_DRIVER_LED_LED_H_
#define SRC_DRIVER_LED_LED_H_

#include "../../HAL/GPIO/GPIO.h"

#define LED_PORT GPIOC

#define LED_PIN_0 GPIO_PIN_0
#define LED_PIN_1 GPIO_PIN_1
#define LED_PIN_2 GPIO_PIN_2
#define LED_PIN_3 GPIO_PIN_3
#define LED_PIN_4 GPIO_PIN_4
#define LED_PIN_5 GPIO_PIN_5
#define LED_PIN_6 GPIO_PIN_6
#define LED_PIN_7 GPIO_PIN_7

void Led_Init();
void LED_OnOff(uint32_t LED_PIN, int OnOff);
void LED_AllOff();

#endif /* SRC_DRIVER_LED_LED_H_ */
