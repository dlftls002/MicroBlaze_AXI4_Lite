#ifndef SRC_HAL_GPIO_GPIO_H_
#define SRC_HAL_GPIO_GPIO_H_

#include "../../common/common.h"

void HAL_GPIO_Init(void); // 방향 설정을 위한 초기화 함수 부활!
uint32_t HAL_GPIO_Read_Button(void);
uint32_t HAL_GPIO_Read_Switch(void);
void HAL_GPIO_Write_LED(uint32_t data);
void HAL_GPIO_Write_FND(uint32_t anode, uint32_t seg);

#endif /* SRC_HAL_GPIO_GPIO_H_ */
