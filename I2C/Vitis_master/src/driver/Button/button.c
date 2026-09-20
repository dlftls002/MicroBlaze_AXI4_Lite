#include "button.h"
#include "../../HAL/GPIO/gpio.h"

uint32_t Button_Read(void) {
    uint32_t current_btn = HAL_GPIO_Read_Button();
    static uint32_t prev_btn = 0; // 이전 상태를 기억하는 변수
    uint32_t btn_pushed = 0;

    // 이전에는 0이었는데 지금 1인 비트만 찾아냄 (Rising Edge 검출)
    btn_pushed = (current_btn ^ prev_btn) & current_btn;

    // 다음 번 비교를 위해 현재 상태 저장
    prev_btn = current_btn;

    return btn_pushed;
}
