#include "i2c.h"
#include "sleep.h"

#define I2C_BASEADDR XPAR_I2C_0_S00_AXI_BASEADDR

// 🚨 수정 1: Verilog의 slv_reg 매핑에 맞게 주소를 똑바로 맞춤!
#define I2C_CTRL_REG    0x00 // slv_reg0: 제어 레지스터
#define I2C_TX_DATA_REG 0x04 // slv_reg1: 데이터 레지스터
#define I2C_RX_DATA_REG 0x08 // slv_reg2: 수신 데이터 (에러 났던 부분!)

// 제어 비트 매핑 (Verilog의 slv_reg0[0], [1], [3] 에 해당)
#define CMD_START 0x01
#define CMD_WRITE 0x02
#define CMD_READ  0x04
#define CMD_STOP  0x08
#define ACK_IN    0x10

void HAL_I2C_Write(uint8_t slave_addr, uint8_t data) {
    uint8_t addr_byte;

    // ==========================================
    // 1단계: START 조건 생성
    // ==========================================
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_START);
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00); // 펄스(Pulse)를 주고 바로 닫음
    usleep(50); // 하드웨어가 START 상태(WAIT_CMD)로 넘어갈 때까지 충분히 대기

    // ==========================================
    // 2단계: 슬레이브 주소(7bit) + Write(0) 전송
    // ==========================================
    addr_byte = (slave_addr << 1) | 0x00; // 0x25 -> 0x4A
    Xil_Out32(I2C_BASEADDR + I2C_TX_DATA_REG, addr_byte); // slv_reg1에 주소 쓰기

    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_WRITE); // 전송(Write) 명령!
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00);
    usleep(200); // 8비트 데이터 + ACK 수신까지 걸리는 시간(약 90us) 이상 넉넉히 대기

    // ==========================================
    // 3단계: 실제 제어 데이터(스위치 값) 전송
    // ==========================================
    Xil_Out32(I2C_BASEADDR + I2C_TX_DATA_REG, data); // slv_reg1에 데이터 쓰기

    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_WRITE); // 전송(Write) 명령!
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00);
    usleep(200); // 8비트 데이터 + ACK 수신까지 대기

    // ==========================================
    // 4단계: STOP 조건 생성
    // ==========================================
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_STOP);
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00);
    usleep(50); // 통신 완전 종료 대기
}

uint8_t HAL_I2C_Read(uint8_t slave_addr) {
    uint8_t addr_byte;
    uint32_t rx_reg_val;
    uint8_t read_data;

    // 1. START 조건
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_START);
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00);
    usleep(50);

    // 2. 슬레이브 주소(7bit) + Read(1) 전송
    addr_byte = (slave_addr << 1) | 0x01; // 0x25 -> 0x4B (맨 끝자리가 1이면 Read!)
    Xil_Out32(I2C_BASEADDR + I2C_TX_DATA_REG, addr_byte);

    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_WRITE); // 주소는 일단 Write로 밀어넣음
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00);
    usleep(200);

    // 3. 실제 데이터 READ 명령
    // (1바이트만 읽고 끊을 것이므로, 슬레이브에게 "더 안 받을게"라는 의미로 NACK(ACK_IN)를 함께 보냄)
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_READ | ACK_IN); // 0x04 | 0x10 = 0x14
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00);
    usleep(200); // 슬레이브가 8비트를 다 보내줄 때까지 대기

    // 4. 수신된 데이터 읽어오기 (slv_reg2의 하위 8비트 추출)
    rx_reg_val = Xil_In32(I2C_BASEADDR + I2C_RX_DATA_REG);
    read_data = (uint8_t)(rx_reg_val & 0xFF);

    // 5. STOP 조건
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, CMD_STOP);
    Xil_Out32(I2C_BASEADDR + I2C_CTRL_REG, 0x00);
    usleep(50);

    return read_data;
}
