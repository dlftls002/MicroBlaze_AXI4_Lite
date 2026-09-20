# MicroBlaze, AXI4-Lite 기반 임베디드 SoC 아키텍처 및 UVM 검증

---

## 1. Project Overview

본 프로젝트는 Xilinx MicroBlaze 소프트 프로세서 코어와 업계 표준인 **AMBA AXI4-Lite 온칩 버스 인터커넥트**를 기반으로, 자체 설계한 통신 IP(SPI Master, I2C Master)를 커스텀 슬레이브 IP로 패키징하고 Vitis C 베어메탈(HAL) 드라이버를 통해 제어하는 **임베디드 풀스택 SoC(System-on-Chip) 플랫폼**입니다.

하드웨어 레벨에서는 CPU가 메모리 매핑 주소(MMIO)를 통해 주변장치 레지스터를 직접 읽고 쓸 수 있는 AXI4-Lite 슬레이브 아키텍처를 설계하였으며, 소프트웨어 레벨에서는 레지스터 오프셋 주소를 포인터 구조체로 제어하는 고신뢰성 HAL 드라이버를 구현하였습니다. 또한 **UVM(Universal Verification Methodology)** 기반의 자동화 검증 환경을 구축하여 AXI4-Lite 및 통신 트랜잭션의 Read/Write 교차 커버리지 100%를 달성하고, Digilent Basys3 FPGA 보드 실장을 통해 Board-to-Board 루프백 통신 및 주변장치 제어를 완벽히 실증하였습니다.

---

## 2. Tech Stack

| Category | Details |
| --- | --- |
| **S/W Environment** | Xilinx Vivado 2022.2, Vitis Unified IDE, Synopsys Verdi, Synopsys VCS, VS Code |
| **H/W Environment** | Digilent Basys 3 AMD Artix®-7 FPGA Board, External Logic Analyzer |
| **Language** | SystemVerilog (RTL & UVM Verification Ecosystem), C-Language (Bare-metal HAL) |
| **Target Protocol** | ARM® AMBA AXI4-Lite Specification, Motorola SPI (Mode 0~3), Philips I2C Bus Standard |

---

## 3. 역할 및 기여도 (Role & Contribution)

| 이름 | 담당 업무 | 기여도 |
| --- | --- | :---: |
| **강동우** | AXI4-Lite 슬레이브 IP 패키징, Vitis C HAL 드라이버 설계, UVM 검증 환경 구축 및 Basys3 FPGA 실장 검증 | **100% (개인)** |

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
|  | - AP Application    |       | (Custom Slave IP)  |  | (Custom Slave IP)  |     |
|  +---------------------+       +--------------------+  +--------------------+     |
|                                           |                      |                |
+-------------------------------------------|----------------------|----------------+
                                            v                      v
                                     [External Slave]       [External Slave]
                                    (FND, LED Control)     (FND, LED Control)
```

### 4.1 하드웨어 IP 레이어 (Hardware IP Layer)
* **AXI4-Lite 슬레이브 인터페이스 설계**: AXI4-Lite 프로토콜 규격(AW, W, B, AR, R 5개 채널 핸드셰이크)을 준수하는 슬레이브 로직을 결합하여, CPU가 접근 가능한 Control, Status, Data 레지스터 매핑 공간 구축.
* **SPI / I2C Master 코어 래핑(Wrapping)**: 단독 동작하던 통신 IP 코어를 AXI4-Lite 슬레이브 규격으로 패키징하여 프로세서 메모리 공간에 결합.

### 4.2 임베디드 소프트웨어 레이어 (Vitis C HAL Layer)
* **포인터 구조체 기반 드라이버 설계**: `.XSA` 파일로 익스포트된 하드웨어 어드레스 맵을 기반으로, 베이스 어드레스와 오프셋을 구조체 포인터로 직접 제어하는 베어메탈 드라이버 API 설계:
  - `HAL_I2C_Write()`, `HAL_I2C_Read()`
  - `SPI_Transfer()`
* **양방향 시퀀스 제어**: 물리 스위치 및 버튼 입력 인터럽트/폴링 시나리오와 연동하여 외부 슬레이브 보드의 FND/LED 디스플레이 코어로 명령을 하달하고, 슬레이브 상태를 CPU 변수로 복귀시키는 실시간 제어 구현.

### 4.3 UVM 검증 서브시스템 (Verification Subsystem)
* **계층화 테스트벤치 구조**: AXI4-Lite 및 I2C/SPI 인터페이스에 대해 `axi_lite_agent`, `i2c_agent`, `driver`, `monitor`, `scoreboard`로 분리된 객체지향 테스트벤치 구축.
* **커버리지 100% 달성**: Constrained Random 시퀀스를 통해 Read/Write 트랜잭션의 모든 코너케이스를 검증하고 Functional & Code Coverage 100% 달성.

---

## 5. Trouble Shooting

### 5.1 I2C Read Mode 수행 시 Slave 응답 불가 및 버스 데드락(Deadlock)
* **현상**: Vitis 소프트웨어에서 I2C 읽기 명령(`HAL_I2C_Read`) 수행 시, 슬레이브 보드로부터 응답이 없고 CPU가 `0xFF` 데이터를 연속으로 수신하며 통신이 중단되는 현상 발생.
* **원인 분석**: 소프트웨어 드라이버에서 통신 시작 명령을 내린 후 제어 레지스터의 Start 비트 초기화 타이밍이 누락되어, Master 하드웨어 FSM이 완료 후에도 Start 상태에서 빠져나오지 못하고 무한 루프에 갇혀 버스 충돌 및 데드락 유발.
* **해결 방법**: 통신 완료(`done`) 플래그가 발생하는 즉시 제어 레지스터의 Start 명령 비트를 1클럭 동안 자동으로 리셋하는 **Auto-clear FSM 방어 로직**을 슬레이브 하드웨어 인터페이스에 추가하여 데드락 문제를 근본적으로 해결.

---

## 6. Verification & Video Demo

레포지토리에 포함된 동작 검증 영상(`*.mp4`)을 통해 실제 Basys3 FPGA 보드 실장 동작을 확인할 수 있습니다:

| 영상 파일명 | 검증 내용 |
| :--- | :--- |
| `260426_AXI4_Lite_gpio_fnd 동작영상.mp4` | MicroBlaze 기반 AXI4-Lite GPIO 레지스터 제어로 7-Segment FND 출력 검증 |
| `260427_fnd_blink.mp4` | 타이머 인터럽트 연동 및 FND 점멸 시퀀스 동작 검증 |
| `260427_fnd_select_blink.mp4` | 스위치 입력에 따른 특정 자릿수 선택 및 점멸 제어 검증 |
| `260428_upcounter + watch.mp4` | 스톱워치/시계 복합 기능 수행 시 레지스터 맵 정합성 및 보드 실장 검증 |

---

## 7. Engineering Insights (고찰)

* **HW-SW 코디자인(Co-design) 역량 강화**: 소프트웨어 드라이버(HAL)의 접근 타이밍과 하드웨어 FSM의 반응 주기를 유기적으로 고려한 안정적인 레지스터 맵 설계의 중요성을 체득.
* **프로토콜 상호운용성 검증**: 프로세서 표준 버스(AXI)와 외부 통신 표준(SPI, I2C)이 결합된 복합 시스템에서, 소프트웨어 제어 오류가 하드웨어 데드락으로 번지지 않도록 방어하는 하드웨어 보호 로직 설계 경험 확보.
