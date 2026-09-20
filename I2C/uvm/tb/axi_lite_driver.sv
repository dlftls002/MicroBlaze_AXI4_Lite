`ifndef AXI_LITE_DRIVER_SV
`define AXI_LITE_DRIVER_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_lite_driver extends uvm_driver#(axi_lite_seq_item);
    `uvm_component_utils(axi_lite_driver) 
    
    virtual axi_lite_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_lite_if)::get(this,"","vif",vif)) begin
            `uvm_fatal(get_type_name(), "driver에서 axi_lite_if uvm_config_db 에러 발생.");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_bus_init();
        wait(vif.aresetn == 1);
        `uvm_info(get_type_name(), "리셋 해제 확인. 트랜잭션 대기 중...", UVM_MEDIUM)

        forever begin
            axi_lite_seq_item tx;
            seq_item_port.get_next_item(tx);
            drive_axi(tx);
            seq_item_port.item_done();
        end      
    endtask 

    task axi_bus_init();
        vif.drv_cb.awaddr  <= 0;
        vif.drv_cb.awvalid <= 0;
        vif.drv_cb.wdata   <= 0;
        vif.drv_cb.wstrb   <= 0;
        vif.drv_cb.wvalid  <= 0;
        vif.drv_cb.bready  <= 0;
        vif.drv_cb.araddr  <= 0;
        vif.drv_cb.arvalid <= 0;
        vif.drv_cb.rready  <= 0;
    endtask 

    task drive_axi(axi_lite_seq_item tx);
        if (tx.write_en) begin
            vif.drv_cb.awaddr  <= tx.addr;
            vif.drv_cb.awvalid <= 1;
            vif.drv_cb.wdata   <= tx.data;
            vif.drv_cb.wstrb   <= 4'hF; 
            vif.drv_cb.wvalid  <= 1;

            fork
                begin
                    do @(vif.drv_cb); while(!vif.drv_cb.awready);
                    vif.drv_cb.awvalid <= 0;
                end
                begin
                    do @(vif.drv_cb); while(!vif.drv_cb.wready);
                    vif.drv_cb.wvalid  <= 0;
                end
            join

            vif.drv_cb.bready <= 1;
            do @(vif.drv_cb); while(!vif.drv_cb.bvalid);
            vif.drv_cb.bready <= 0;
            
        end else begin
            vif.drv_cb.araddr <= tx.addr;
            vif.drv_cb.arvalid <= 1;
            do @(vif.drv_cb); while(!vif.drv_cb.arready);
            vif.drv_cb.arvalid <= 0;

            vif.drv_cb.rready <= 1;
            do @(vif.drv_cb); while(!vif.drv_cb.rvalid);
            tx.rdata = vif.drv_cb.rdata; 
            vif.drv_cb.rready <= 0;
        end

        `uvm_info(get_type_name(), $sformatf("AXI 구동 완료: %s", tx.convert2string()), UVM_MEDIUM)
    endtask 

endclass 

`endif