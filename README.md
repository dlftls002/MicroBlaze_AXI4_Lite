# MicroBlaze AXI4-Lite 기반 SPI / I2C SoC 시스템 구축 및 UVM 검증

> **온디바이스 AI 시스템반도체 설계 1기 프로젝트**  
> **개발 기간:** 2026. 04. 21 ~ 2026. 05. 08 (약 3주)  
> **팀원 구성:** 강동우, 조준호 (2인)  

---

## 1. Project Overview

본 프로젝트는 Xilinx MicroBlaze 32-bit 소프트 프로세서와 **AMBA AXI4-Lite 온칩 버스 인터커넥트**를 기반으로, 자체 설계한 통신 IP(SPI Master, I2C Master)를 커스텀 슬레이브 IP로 패키징하고 Vitis C 베어메탈 드라이버를 통해 제어하는 **임베디드 풀스택 SoC(System-on-Chip) 플랫폼**입니다.

하드웨어 레벨에서는 AXI4-Lite의 5개 독립 채널(AW, W, B, AR, R) 규격을 준수하는 슬레이브 인터페이스를 구현하여 CPU 메모리 주소 공간(MMIO)에 통신 IP를 결합하였으며, 소프트웨어 레벨에서는 레지스터 맵 기반의 고신뢰성 C HAL 드라이버를 작성하여 하드웨어-소프트웨어 통합 제어를 구현하였습니다.

또한 **UVM(Universal Verification Methodology)** 기반의 자동화 검증 환경을 구축하여 1,000회의 무작위 트랜잭션 테스트를 수행함으로써 **레지스터 R/W 교차 커버리지 100%**를 달성하였고, Digilent Basys3 FPGA 보드 실장을 통해 Board-to-Board 통신 및 주변장치(FND, LED, Switch) 제어를 완벽히 실증하였습니다.

---

## 2. Tech Stack

| Category | Details |
| --- | --- |
| **S/W Environment** | Xilinx Vivado 2020.2, Vitis Unified IDE, Synopsys Verdi, Synopsys VCS, VS Code |
| **H/W Environment** | Digilent Basys 3 AMD Artix®-7 FPGA Board, External Logic Analyzer |
| **Language** | Verilog HDL, SystemVerilog (UVM Verification Ecosystem), C-Language |
| **Target Protocol** | ARM® AMBA AXI4-Lite Specification, Motorola SPI (Mode 0), Philips I2C Bus Standard |

---

## 3. 역할 및 기여도 (Role & Contribution)

| 팀원 | 담당 업무 |
| :---: | :--- |
| **강동우** | AXI4-Lite 슬레이브 IP 패키징, Vitis C 드라이버(HAL) 설계, UVM 검증 환경 구축 및 트러블슈팅, Basys3 보드 실장 검증 |
| **조준호** | AXI4-Lite 주변장치 인터페이스 연동, Vivado Block Design 통합 및 하드웨어 데모 검증 |

---

## 4. Architecture & Subsystems

```
+-----------------------------------------------------------------------------------+
|                                Digilent Basys 3 FPGA                              |
|                                                                                   |
|  +---------------------+            AMBA AXI4-Lite Interconnect                   |
|  | MicroBlaze CPU Core |<==================================+                      |
|  |  (32-bit Soft Core) |                                   |                      |
|  +---------------------+                                   v                      |
|             |                       +------------------------------------------+  |
|             | (.XSA Hardware Handoff| AXI4-Lite Interconnect Matrix            |  |
|             v                       +------------------------------------------+  |
|  +---------------------+                  |                     |                 |
|  | Vitis C Software    |                  v                     v                 |
|  | - HAL Drivers       |       +--------------------+  +--------------------+     |
|  | - Register Maps     |       | AXI_I2C Master IP  |  | AXI_SPI Master IP  |     |
|  | - AP Main Loop      |       | (Custom Slave IP)  |  | (Custom Slave IP)  |     |
|  +---------------------+       +--------------------+  +--------------------+     |
|                                           |                      |                |
+-------------------------------------------|----------------------|----------------+
                                            v                      v
                                     [External Slave]       [External Slave]
                                    (FND, LED Control)     (FND, LED Control)
```

### 4.1 AXI4-Lite 버스 아키텍처
* **5개 독립 채널 및 VALID/READY Handshake**:
  - `AW (Write Address)`: Master가 쓰기 주소를 인가하고 Slave가 수락
  - `W (Write Data)`: Master가 데이터를 인가하고 Slave가 수락
  - `B (Write Response)`: Slave가 쓰기 완료 응답을 반환
  - `AR (Read Address)`: Master가 읽기 주소를 인가하고 Slave가 수락
  - `R (Read Data)`: Slave가 읽은 데이터를 반환하고 Master가 수락
* **Point-to-Point 직접 연결**: 별도의 중재 지연을 최소화하여 레지스터 설정 및 저속 I/O 제어에 최적화된 저면적 아키텍처 구현.

### 4.2 AXI_SPI 서브시스템 (AXI_SPI Subsystem)
* MicroBlaze와 커스텀 SPI Master IP를 AXI4-Lite로 연동하여 외부 SPI 슬레이브 제어.
* 스위치 입력 값을 Master와 Slave의 `tx_data`로 사용하여 상호 전송하고, 수신된 `rx_data`를 7-Segment FND 및 LED로 실시간 출력 검증.

### 4.3 AXI_I2C 서브시스템 및 레지스터 맵 (AXI_I2C & Register Map)
MicroBlaze가 I2C Master IP를 제어하기 위한 오프셋 레지스터 맵을 구성:

| Register | Offset | Bit / Function | Description |
| :--- | :---: | :---: | :--- |
| **CR (Control Register)** | `0x00` | `[1]`: START, `[3]`: STOP | I2C 선로에 START(0x02) 및 STOP(0x08) 조건 발생 제어 |
| **TX_REG (Tx Data)** | `0x04` | `[7:0]`: Tx Data | I2C 버스를 통해 전송할 데이터 적재 |
| **SR (Status Register)** | `0x08` | `[0]`: BUSY | 통신 진행 여부 폴링(Polling) 확인 |
| **Unused / Reserved** | `0x0C` | - | 미사용 영역 (예외 접근 검증용) |

### 4.4 UVM 검증 서브시스템 (UVM Verification)
* **계층화 테스트벤치**: `axi_lite_agent`, `i2c_agent`, `driver`, `monitor`, `scoreboard`로 분리된 객체지향 검증 환경 구축.
* **검증 시나리오 및 커버리지**:
  - AXI Write를 통한 TX_REG 데이터 적재 ➔ START 조건 발생 ➔ Status Register Busy 폴링 ➔ End-to-End Scoreboard 비교.
  - **1,000회 Random Transaction 테스트**를 수행하여 Register 접근, R/W 동작, 미사용 주소(0x0C) 접근을 포함한 **교차 커버리지(Cross Coverage) 100% 달성**.

---

## 5. Trouble Shooting

### ■ I2C Read Mode 수행 시 Slave 응답 불가 및 버스 충돌 (0xFF 연속 수신)
* **현상**: Vitis 펌웨어에서 I2C Read 시퀀스를 구동할 때, 슬레이브 보드로부터 응답이 없고 CPU가 `0xFF` 데이터를 연속으로 수신하며 버스가 먹통이 되는 현상 발생.
* **원인 분석**: 소프트웨어 드라이버에서 통신 시작 명령을 보낸 후 제어 레지스터(CR)의 Start 명령 비트 초기화 타이밍이 누락됨. 이로 인해 Master 하드웨어 FSM이 통신 완료 후에도 Start 상태를 유지하며 무한 루프에 빠져 버스 충돌(Deadlock) 유발.
* **해결 방법**: 통신 완료(`done`) 플래그가 발생하는 즉시 제어 레지스터의 Start 명령 비트를 1클럭 동안 자동으로 리셋하는 **Auto-clear FSM 방어 로직**을 슬레이브 하드웨어 인터페이스에 추가하여, 소프트웨어의 단발성 제어를 보장하고 정상적인 데이터 수신을 성공적으로 달성.

---

## 6. Verification & Video Demo

레포지토리에 포함된 동작 검증 영상(`*.mp4`)을 통해 Basys3 FPGA 보드 실장 동작을 확인할 수 있습니다:

| 영상 파일명 | 검증 내용 |
| :--- | :--- |
| `260426_AXI4_Lite_gpio_fnd 동작영상.mp4` | MicroBlaze 기반 AXI4-Lite GPIO 레지스터 제어로 7-Segment FND 출력 검증 |
| `260427_fnd_blink.mp4` | 타이머 인터럽트 연동 및 FND 점멸 시퀀스 동작 검증 |
| `260427_fnd_select_blink.mp4` | 스위치 입력에 따른 특정 자릿수 선택 및 점멸 제어 검증 |
| `260428_upcounter + watch.mp4` | 스톱워치/시계 복합 기능 수행 시 레지스터 맵 정합성 및 보드 실장 검증 |

---

## 7. Engineering Insights (고찰)

* **하드웨어-소프트웨어 상호작용 이해**: C 언어를 활용한 레지스터 제어 누락이 전체 하드웨어 FSM의 타이밍 오류 및 버스 데드락으로 직결될 수 있음을 체득하며, 소프트웨어 드라이버와 하드웨어 간의 정밀한 타이밍 동기화 중요성을 체감.
* **표준 버스 프로토콜 확장성**: AMBA AXI4-Lite 표준 버스 구조를 바탕으로 자체 통신 IP(SPI, I2C)를 모듈화하여 패키징함으로써, 대규모 SoC 환경에서 재사용 가능한 IP 블록 설계 역량을 확립.
