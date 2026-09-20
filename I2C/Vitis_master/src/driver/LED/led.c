#include "led.h"
#include "../../HAL/I2C/i2c.h"

void LED_Display(uint8_t led_data) {
    HAL_I2C_Write(I2C_SLAVE_ADDR, led_data);
}
