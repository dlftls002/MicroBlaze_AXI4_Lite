`ifndef AXI_LITE_MONITOR_SV
`define AXI_LITE_MONITOR_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi_lite_monitor)

    uvm_analysis_port #(axi_lite_seq_item) ap;
    virtual axi_lite_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);   
        if (!uvm_config_db#(virtual axi_lite_if)::get(this,"","vif",vif)) begin
            `uvm_fatal(get_type_name(), "monitor에서 axi_lite_if uvm_config_db 에러 발생.");
        end 
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "AXI4-Lite 버스 모니터링 시작 ...", UVM_MEDIUM)
        fork
            collect_write_transactions();
            collect_read_transactions();
        join
    endtask 

    task collect_write_transactions();
        axi_lite_seq_item tx;
        forever begin
            tx = axi_lite_seq_item::type_id::create("mon_tx_w");
            tx.write_en = 1;

            fork
                begin // 1. Write Address 캡처
                    do @(vif.mon_cb); while(!(vif.mon_cb.awvalid && vif.mon_cb.awready));
                    tx.addr = vif.mon_cb.awaddr;
                end
                begin // 2. Write Data 캡처
                    do @(vif.mon_cb); while(!(vif.mon_cb.wvalid && vif.mon_cb.wready));
                    tx.data = vif.mon_cb.wdata;
                end
            join

            // 3. Write Response 캡처 (B)
            do @(vif.mon_cb); while(!(vif.mon_cb.bvalid && vif.mon_cb.bready));
            tx.resp = vif.mon_cb.bresp;

            `uvm_info(get_type_name(), $sformatf("AXI Write 감지: %s", tx.convert2string()), UVM_HIGH)
            ap.write(tx); 
        end
    endtask 

    task collect_read_transactions();
        axi_lite_seq_item tx;
        forever begin
            tx = axi_lite_seq_item::type_id::create("mon_tx_r");
            tx.write_en = 0;

            do @(vif.mon_cb); while(!(vif.mon_cb.arvalid && vif.mon_cb.arready));
            tx.addr = vif.mon_cb.araddr;

            do @(vif.mon_cb); while(!(vif.mon_cb.rvalid && vif.mon_cb.rready));
            tx.rdata = vif.mon_cb.rdata;
            tx.resp = vif.mon_cb.rresp;

            `uvm_info(get_type_name(), $sformatf("AXI Read 감지: %s", tx.convert2string()), UVM_HIGH)
            ap.write(tx); 
        end
    endtask 

endclass 

`endif