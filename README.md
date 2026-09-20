# MicroBlaze, AXI4-Lite 기반 임베디드 SoC 아키텍처 및 UVM 검증

> **개발 기간:** 2026. 04. 21 ~ 2026. 05. 08  
> **개발 환경:** Xilinx Vivado 2022.2, Vitis IDE, Synopsys VCS, Verdi, Basys3 FPGA  
> **사용 언어:** SystemVerilog, C, UVM  

---

## 1. 프로젝트 개요 (Overview)

Xilinx MicroBlaze 소프트 프로세서와 AMBA AXI4-Lite 버스 규격을 기반으로, 통신 IP(SPI Master, I2C Master)를 커스텀 슬레이브 IP로 패키징하여 프로세서가 접근 가능한 하드웨어 레지스터 매핑 공간을 설계한 온칩 SoC 시스템입니다.

Vitis 환경에서 레지스터 오프셋 주소를 포인터 구조체로 직접 제어하는 C 베어메탈(HAL) 드라이버를 작성하여 하드웨어-소프트웨어 통합 제어를 구현하였으며, UVM 계층화 테스트벤치를 구축하여 AXI4-Lite 및 통신 인터페이스에 대한 자동화 검증을 완료하였습니다.

---

## 2. 시스템 아키텍처 (System Architecture)

```
+-------------------------------------------------------------------+
|                        Basys3 FPGA System                         |
|                                                                   |
|  +------------------+         AMBA AXI4-Lite                      |
|  | MicroBlaze Core  |<======================+                     |
|  | (Soft Processor) |                       |                     |
|  +------------------+                       v                     |
|           |                 +----------------------------------+  |
|           | (.XSA)          | AXI4-Lite Interconnect           |  |
|           v                 +----------------------------------+  |
|  +------------------+             |                      |        |
|  | Vitis C Software |             v                      v        |
|  | - HAL Drivers    |   +------------------+   +---------------+  |
|  | - Register Maps  |   | AXI_I2C Master IP|   |AXI_SPI Master |  |
|  +------------------+   +------------------+   +---------------+  |
|                                   |                      |        |
+-----------------------------------|----------------------|--------+
                                    v                      v
                             [External Slave]       [External Slave]
                               (FND / LED)            (FND / LED)
```

### 주요 구현 기능
1. **하드웨어 IP 레이어 (Vivado)**
   - AMBA AXI4-Lite 슬레이브 인터페이스 로직을 설계하여 내부 Control/Status/Data 레지스터 맵 매핑.
   - I2C Master 및 SPI Master 코어를 AXI4-Lite 슬레이브로 래핑(Wrapping)하여 CPU 메모리 주소 공간에 통합.
2. **임베디드 소프트웨어 레이어 (Vitis)**
   - 하드웨어 내보내기(`.XSA`)를 기반으로 레지스터 오프셋 주소를 포인터 구조체로 제어하는 C HAL 드라이버 구현:
     - `HAL_I2C_Write()`, `HAL_I2C_Read()`, `SPI_Transfer()`
   - 물리 스위치 및 버튼 입력에 따라 외부 슬레이브 보드의 FND/LED 디스플레이를 실시간 제어하고 슬레이브 상태를 CPU 변수로 복귀시키는 양방향 시퀀스 핸들링.
3. **UVM 검증 환경 (Verification)**
   - AXI4-Lite 프로토콜 및 I2C/SPI 인터페이스에 대한 Driver, Monitor, Scoreboard 기반 UVM 계층화 테스트벤치 구축.
   - Constrained Random 데이터를 인가하여 Read/Write 트랜잭션 교차 커버리지 100% 달성.

---

## 3. 디렉토리 구조 (Directory Structure)

```text
├── I2C/
│   ├── Vitis_master/       # MicroBlaze C HAL 드라이버 소스코드 및 XSA 파일
│   ├── Vivado_slave/       # AXI4-Lite I2C 슬레이브 RTL 설계 소스
│   └── uvm/                # I2C AXI4-Lite UVM 검증 환경 (Driver, Monitor, Scoreboard, TB)
├── SPI/
│   ├── Vitis_master/       # MicroBlaze C HAL 드라이버 소스코드 및 XSA 파일
│   └── Vivado_slave/       # AXI4-Lite SPI 슬레이브 RTL 설계 소스
└── *.mp4                   # Basys3 보드 실장 동작 검증 영상 (GPIO, FND, Counter)
```

---

## 4. 트러블슈팅 및 문제 해결 (Trouble Shooting)

### ■ I2C Read Mode 수행 시 슬레이브 응답 불가 및 0xFF 연속 수신
* **원인**: 소프트웨어 드라이버에서 통신 시작 명령을 보낸 후 제어 레지스터의 Start 비트 초기화 타이밍이 누락되어, Master 하드웨어 FSM이 무한 루프에 진입하고 버스 충돌(Deadlock) 발생.
* **해결**: 통신 완료(`done`) 플래그 발생 시 제어 레지스터의 Start 명령 비트를 1클럭 동안 자동으로 리셋하는 **Auto-clear FSM 방어 로직**을 하드웨어에 추가하여 데드락 문제 완벽 해결.

---

## 5. 엔지니어링 고찰 (Takeaway)

* 소프트웨어 드라이버(HAL)의 접근 타이밍과 하드웨어 FSM의 반응 주기를 유기적으로 고려한 안정적인 레지스터 맵 설계의 중요성을 체득.
* 프로세서 버스 규격(AMBA AXI)을 준수하는 하드웨어 IP 패키징 및 하드웨어-소프트웨어 풀스택 통합 검증 역량 확보.
