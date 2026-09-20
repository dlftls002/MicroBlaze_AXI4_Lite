#ifndef SRC_HAL_SPI_SPI_H_
#define SRC_HAL_SPI_SPI_H_

#include <stdint.h>

typedef struct {
	uint32_t CR;      // 0x00 control
	uint32_t CLKDIV;  // 0x04 clk_div
	uint32_t TXDATA;  // 0x08 tx_data
	uint32_t RXDATA;  // 0x0C rx_data
} SPI_Typedef_t;

#define SPI_BASE_ADDR 0x44A00000   // 네 Address Editor에서 확인한 SPI base 주소로 바꿔야 함

#define SPI0 ((SPI_Typedef_t *) SPI_BASE_ADDR)

#define SPI_CPOL_BIT    (1 << 0)
#define SPI_CPHA_BIT    (1 << 1)
#define SPI_START_BIT   (1 << 2)
#define SPI_DONE_BIT    (1 << 3)
#define SPI_BUSY_BIT    (1 << 4)
//#define SPI_CS_N_BIT    (1 << 5)

void SPI_SetClkDiv(uint8_t clk_div);
void SPI_SetTxData(uint8_t data);
void SPI_Start(uint8_t cpol, uint8_t cpha);
uint32_t SPI_ReadStatus(void);
uint8_t SPI_IsDone(void);
uint8_t SPI_IsBusy(void);
uint8_t SPI_ReadRxData(void);
uint8_t SPI_Transfer(uint8_t tx_data);

#endif /* SRC_HAL_SPI_SPI_H_ */
