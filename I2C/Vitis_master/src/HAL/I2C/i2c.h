/*
 * i2c.h
 *
 *  Created on: 2026. 5. 5.
 *      Author: kccistc
 */

#ifndef SRC_HAL_I2C_I2C_H_
#define SRC_HAL_I2C_I2C_H_

#include <stdint.h>  // uint8_t 같은 자료형을 쓰기 위해 반드시 필요!

// 외부에서 가져다 쓸 수 있도록 함수의 '명함'을 모두 선언해 둡니다.
void HAL_I2C_Write(uint8_t slave_addr, uint8_t data);
uint8_t HAL_I2C_Read(uint8_t slave_addr);

#endif /* SRC_HAL_I2C_I2C_H_ */
