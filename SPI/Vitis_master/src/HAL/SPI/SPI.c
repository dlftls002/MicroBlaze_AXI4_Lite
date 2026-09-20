#include "SPI.h"

void SPI_SetClkDiv(uint8_t clk_div)
{
    SPI0->CLKDIV = clk_div;
}

void SPI_SetTxData(uint8_t data)
{
    SPI0->TXDATA = data;
}

void SPI_Start(uint8_t cpol, uint8_t cpha)
{
    uint32_t control = 0;

    if (cpol) control |= SPI_CPOL_BIT;
    if (cpha) control |= SPI_CPHA_BIT;

    SPI0->CR = control | SPI_START_BIT;  // start = 1
    SPI0->CR = control;                  // start = 0
}

uint32_t SPI_ReadStatus(void)
{
    return SPI0->CR;
}

uint8_t SPI_IsDone(void)
{
    return (SPI0->CR & SPI_DONE_BIT) ? 1 : 0;
}

uint8_t SPI_IsBusy(void)
{
    return (SPI0->CR & SPI_BUSY_BIT) ? 1 : 0;
}

uint8_t SPI_ReadRxData(void)
{
    return (uint8_t)(SPI0->RXDATA & 0xFF);
}

uint8_t SPI_Transfer(uint8_t tx_data)
{
    SPI_SetTxData(tx_data);
    SPI_Start(0, 0);

    while (!SPI_IsDone());

    return SPI_ReadRxData();
}
