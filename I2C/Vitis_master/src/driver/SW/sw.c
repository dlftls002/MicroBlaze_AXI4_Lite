#include "sw.h"
#include "../../HAL/GPIO/gpio.h"

uint32_t SW_Read(void) {
    return HAL_GPIO_Read_Switch();
}
