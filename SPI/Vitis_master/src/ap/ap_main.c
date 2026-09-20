#include "ap_main.h"

hBtn_t hbtnStart;

static uint8_t tx_data = 0;
//static uint8_t rx_data = 0;
//static uint8_t last_tx_data = 0;

void ap_init() {
	Button_Init(&hbtnStart, GPIOA, GPIO_PIN_6);

	Led_Init();
	Switch_Init();
	FND_Init();

	SPI_SetClkDiv(49);     // 처음에는 느리게 시작. 필요하면 값 조절

	FND_SetNum(0);
	LED_AllOff();
}

void ap_execute() {
	FND_DispDigit();

	tx_data = Switch_Read();
	GPIO_WritePort(GPIOC, tx_data);

//	FND_SetNum(tx_data);

	if (Button_GetState(&hbtnStart) == ACT_PUSHED) {
		if (!SPI_IsBusy()) {

//			SPI_Transfer(tx_data);

			// 수신 데이터를 확인하고 싶은 경우
			uint8_t rx_data = SPI_Transfer(tx_data);
			FND_SetNum(rx_data);
		}
	}
}
