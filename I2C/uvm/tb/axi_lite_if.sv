`timescale 1ns / 1ps

interface axi_lite_if #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
) (
    input logic aclk,
    input logic aresetn
);

    // ==========================================
    // AXI4-Lite Signals
    // ==========================================
    // 1. Write Address Channel
    logic [C_S_AXI_ADDR_WIDTH-1:0] awaddr;
    logic [2:0]                    awprot;
    logic                          awvalid;
    logic                          awready;

    // 2. Write Data Channel
    logic [C_S_AXI_DATA_WIDTH-1:0] wdata;
    logic [(C_S_AXI_DATA_WIDTH/8)-1:0] wstrb;
    logic                          wvalid;
    logic                          wready;

    // 3. Write Response Channel
    logic [1:0]                    bresp;
    logic                          bvalid;
    logic                          bready;

    // 4. Read Address Channel
    logic [C_S_AXI_ADDR_WIDTH-1:0] araddr;
    logic [2:0]                    arprot;
    logic                          arvalid;
    logic                          arready;

    // 5. Read Data Channel
    logic [C_S_AXI_DATA_WIDTH-1:0] rdata;
    logic [1:0]                    rresp;
    logic                          rvalid;
    logic                          rready;

    // ==========================================
    // Clocking Blocks
    // ==========================================
    // Driver Clocking Block (Master -> DUT)
    clocking drv_cb @(posedge aclk);
        default input #1step output #0;
        
        // Master에서 DUT로 나가는 출력
        output awaddr, awprot, awvalid;
        output wdata, wstrb, wvalid;
        output bready;
        output araddr, arprot, arvalid;
        output rready;
        
        // DUT에서 Master로 들어오는 입력 (ACK 신호들)
        input  awready;
        input  wready;
        input  bresp, bvalid;
        input  arready;
        input  rdata, rresp, rvalid;
    endclocking

    // Monitor Clocking Block (신호 관찰용)
    clocking mon_cb @(posedge aclk);
        default input #1step;
        
        input awaddr, awprot, awvalid, awready;
        input wdata, wstrb, wvalid, wready;
        input bresp, bvalid, bready;
        input araddr, arprot, arvalid, arready;
        input rdata, rresp, rvalid, rready;
    endclocking

    // ==========================================
    // Modports
    // ==========================================
    modport mp_drv(clocking drv_cb, input aclk, input aresetn);
    modport mp_mon(clocking mon_cb, input aclk, input aresetn);

endinterface