#include "ap_main.h"
#include "../HAL/GPIO/gpio.h"
#include "../driver/SW/sw.h"
#include "../driver/Button/button.h"
#include "../driver/LED/led.h"
#include "../HAL/I2C/i2c.h"
#include "sleep.h"
#include <stdio.h>         // printf 사용
#include "xil_printf.h"    // xil_printf 사용

// FND 0~9, A~F 폰트 배열 (Active Low 기준)
const uint8_t fnd_font[16] = {
    0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8,
    0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E
};

void AP_Init(void) {
    HAL_GPIO_Init(); // 하드웨어 I/O 방향 설정
}

void AP_Main(void) {
    uint32_t sw_val = 0;
    uint32_t btn_val = 0;

    // 🚨 [새로 추가] Read 값을 저장하고 화면 모드를 결정할 변수들
    uint8_t slave_read_val = 0;
    uint8_t display_mode = 0;   // 0: 마스터 스위치 화면, 1: 슬레이브 읽기 화면
    uint32_t target_val = 0;    // FND에 최종적으로 띄울 값

    // FND 다이내믹 구동을 위한 변수들 추가
    uint8_t fnd_digit = 0; // 현재 켤 자리수 인덱스 (0~3)
    uint32_t anode_val[4] = {0x0E, 0x0D, 0x0B, 0x07}; // 1의자리, 10의자리, 100의자리, 1000의자리 (Active Low)
    uint8_t display_data[4] = {0, 0, 0, 0}; // 각 자리에 표시할 숫자 담는 배열

    AP_Init(); // 초기화 실행

    while(1) {
        // 1. 스위치 값과 버튼 값 실시간 읽기
        sw_val = SW_Read();
        btn_val = Button_Read();

        // 2. 버튼 입력에 따른 동작 수행 및 화면 모드 전환
        if (btn_val & 0x01) {
            // 첫 번째 버튼: Write (마스터 -> 슬레이브)
            LED_Display((uint8_t)sw_val);
            xil_printf("I2C Write to Slave: %d\r\n", (int)sw_val);
            display_mode = 0; // 🚨 다시 마스터 스위치를 보도록 모드 변경
        }
        else if (btn_val & 0x02) {
            // 두 번째 버튼: Read (슬레이브 -> 마스터)
            slave_read_val = HAL_I2C_Read(I2C_SLAVE_ADDR);
            xil_printf("I2C Read from Slave Switch: %d\r\n", (int)slave_read_val);
            display_mode = 1; // 🚨 슬레이브 값을 보도록 모드 변경
        }

        // 3. FND에 띄울 최종 값(target_val) 결정
        if (display_mode == 0) {
            target_val = sw_val;         // 평소에는 내 보드의 스위치 값
        } else {
            target_val = slave_read_val; // Read 버튼을 누른 후에는 읽어온 값
        }

        // 4. 4자리 표시를 위해 최종 값(target_val)을 10진수 각 자리별로 분리
        // (기존 sw_val 대신 target_val을 분리합니다)
        display_data[0] = target_val % 10;            // 1의 자리 숫자
        display_data[1] = (target_val / 10) % 10;     // 10의 자리 숫자
        display_data[2] = (target_val / 100) % 10;    // 100의 자리 숫자
        display_data[3] = (target_val / 1000) % 10;   // 1000의 자리 숫자

        // 5. 마스터 로컬 디스플레이 실시간 업데이트
        HAL_GPIO_Write_LED(sw_val); // LED는 마스터의 스위치 상태를 항상 보여줌 (헷갈림 방지)

        // 6. FND 다이내믹 구동 (잔상 효과)
        HAL_GPIO_Write_FND(anode_val[fnd_digit], fnd_font[display_data[fnd_digit]]);

        // 다음 루프에서는 다음 자리수를 켜기 위해 인덱스 증가
        fnd_digit = (fnd_digit + 1) % 4;

        // 7. 짧은 딜레이
        usleep(2500); // 2.5ms 대기
    }
}
