#include "fnd.h"
#include "../../HAL/I2C/i2c.h"

void FND_Display(uint8_t fnd_data) {
    // 슬레이브 주소(0x25)로 FND 출력용 데이터를 I2C Write!
    HAL_I2C_Write(I2C_SLAVE_ADDR, fnd_data);
}
