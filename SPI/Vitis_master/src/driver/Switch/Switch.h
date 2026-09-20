

#ifndef SRC_DRIVER_SWITCH_SWITCH_H_
#define SRC_DRIVER_SWITCH_SWITCH_H_

#include "../../HAL/GPIO/GPIO.h"

#define SW_PIN_0 GPIO_PIN_0
#define SW_PIN_1 GPIO_PIN_1
#define SW_PIN_2 GPIO_PIN_2
#define SW_PIN_3 GPIO_PIN_3
#define SW_PIN_4 GPIO_PIN_4
#define SW_PIN_5 GPIO_PIN_5
#define SW_PIN_6 GPIO_PIN_6
#define SW_PIN_7 GPIO_PIN_7

void Switch_Init();
uint8_t Switch_Read();

#endif /* SRC_DRIVER_SWITCH_SWITCH_H_ */
