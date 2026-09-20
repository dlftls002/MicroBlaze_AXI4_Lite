`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "axi_lite_if.sv"
`include "i2c_if.sv"

`include "axi_lite_seq_item.sv"
`include "i2c_seq_item.sv"
`include "axi_lite_sequence.sv"

`include "axi_lite_driver.sv"
`include "i2c_slave_driver.sv"
`include "axi_lite_monitor.sv"
`include "i2c_monitor.sv"

`include "axi_lite_agent.sv"
`include "i2c_slave_agent.sv"

`include "i2c_scoreboard.sv"
`include "i2c_coverage.sv"
`include "i2c_env.sv"
`include "i2c_test.sv"

module tb_top ();

    logic aclk;
    logic aresetn;

    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk; // 100MHz 클럭 생성
    end

    initial begin
        aresetn = 0;
        repeat (5) @(posedge aclk);
        aresetn = 1; // 5클럭 후 리셋 해제
    end

    axi_lite_if axi_vif (
        .aclk   (aclk),
        .aresetn(aresetn)
    );

    i2c_if i2c_vif ();

    i2c_v1_0 #(
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) dut (
        // AXI Global
        .s00_axi_aclk   (aclk),
        .s00_axi_aresetn(aresetn),
        
        // AXI Write Address Channel
        .s00_axi_awaddr (axi_vif.awaddr),
        .s00_axi_awprot (axi_vif.awprot),
        .s00_axi_awvalid(axi_vif.awvalid),
        .s00_axi_awready(axi_vif.awready),
        
        // AXI Write Data Channel
        .s00_axi_wdata  (axi_vif.wdata),
        .s00_axi_wstrb  (axi_vif.wstrb),
        .s00_axi_wvalid (axi_vif.wvalid),
        .s00_axi_wready (axi_vif.wready),
        
        // AXI Write Response Channel
        .s00_axi_bresp  (axi_vif.bresp),
        .s00_axi_bvalid (axi_vif.bvalid),
        .s00_axi_bready (axi_vif.bready),
        
        // AXI Read Address Channel
        .s00_axi_araddr (axi_vif.araddr),
        .s00_axi_arprot (axi_vif.arprot),
        .s00_axi_arvalid(axi_vif.arvalid),
        .s00_axi_arready(axi_vif.arready),
        
        // AXI Read Data Channel
        .s00_axi_rdata  (axi_vif.rdata),
        .s00_axi_rresp  (axi_vif.rresp),
        .s00_axi_rvalid (axi_vif.rvalid),
        .s00_axi_rready (axi_vif.rready),

        // I2C Physical Ports
        .scl            (i2c_vif.scl),
        .sda            (i2c_vif.sda)
    );

    initial begin
        uvm_config_db#(virtual axi_lite_if)::set(null, "*", "vif", axi_vif);
        uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", i2c_vif);
        
        run_test("i2c_tx_test");     
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_top, "+all");
    end

endmodule