#include "gpio.h"

// Base Address
#define BUTTON_BASEADDR XPAR_GPIO8_0_S00_AXI_BASEADDR // GPIOA (입력:버튼, 출력:FND Anode)
#define FND_SEG_BASE    XPAR_GPIO8_1_S00_AXI_BASEADDR // GPIOB (출력:FND Seg)
#define LED_BASE        XPAR_GPIO8_2_S00_AXI_BASEADDR // GPIOC (출력:LED)
#define SWITCH_BASE     XPAR_GPIO8_3_S00_AXI_BASEADDR // GPIOD (입력:스위치)

// Verilog 코드(slv_reg0, 1, 2)에 맞춘 주소 오프셋
#define GPIO_DIR_OFFSET  0x00 // cr
#define GPIO_IN_OFFSET   0x04 // idr
#define GPIO_OUT_OFFSET  0x08 // odr

void HAL_GPIO_Init(void) {
    // 1(출력), 0(입력) 방향 설정 (cr 레지스터에 기록)
    // GPIOA: 하위 4비트는 FND Anode(출력), 상위 4비트는 버튼(입력) -> 0x0F
    Xil_Out32(BUTTON_BASEADDR + GPIO_DIR_OFFSET, 0x0F);

    // GPIOB: FND 세그먼트는 모두 출력 -> 0xFF
    Xil_Out32(FND_SEG_BASE + GPIO_DIR_OFFSET, 0xFF);

    // GPIOC: LED는 모두 출력 -> 0xFF
    Xil_Out32(LED_BASE + GPIO_DIR_OFFSET, 0xFF);

    // GPIOD: 스위치는 모두 입력 -> 0x00
    Xil_Out32(SWITCH_BASE + GPIO_DIR_OFFSET, 0x00);
}

uint32_t HAL_GPIO_Read_Button(void) {
    // idr(0x04)에서 읽어옴. 버튼은 상위 4비트이므로 >> 4
    return (Xil_In32(BUTTON_BASEADDR + GPIO_IN_OFFSET) >> 4) & 0x0F;
}

uint32_t HAL_GPIO_Read_Switch(void) {
    // idr(0x04)에서 읽어옴
    return Xil_In32(SWITCH_BASE + GPIO_IN_OFFSET) & 0xFF;
}

void HAL_GPIO_Write_LED(uint32_t data) {
    // odr(0x08)에 씀
    Xil_Out32(LED_BASE + GPIO_OUT_OFFSET, data);
}

void HAL_GPIO_Write_FND(uint32_t anode, uint32_t seg) {
    // odr(0x08)에 씀
    Xil_Out32(BUTTON_BASEADDR + GPIO_OUT_OFFSET, anode & 0x0F);
    Xil_Out32(FND_SEG_BASE + GPIO_OUT_OFFSET, seg);
}
