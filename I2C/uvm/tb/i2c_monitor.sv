`ifndef I2C_MONITOR_SV
`define I2C_MONITOR_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)

    uvm_analysis_port #(i2c_seq_item) ap;
    virtual i2c_if vif;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);   
        if (!uvm_config_db#(virtual i2c_if)::get(this,"","vif",vif)) `uvm_fatal("NO_VIF", "vif error")
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "I2C 물리 버스 모니터링 시작 ...", UVM_MEDIUM)
        
        forever begin
            i2c_seq_item tx = i2c_seq_item::type_id::create("mon_tx_i2c");
            
            @(negedge vif.sda iff vif.scl === 1'b1);
            
            for(int i=7; i>=0; i--) begin
                @(posedge vif.scl);
                if(i > 0) tx.slave_addr[i-1] = vif.sda;
                else      tx.is_read = vif.sda;
            end
            
            @(posedge vif.scl);
            
            for(int i=7; i>=0; i--) begin
                @(posedge vif.scl);
                tx.data[i] = vif.sda;
            end
            
            @(posedge vif.scl);
            
            @(posedge vif.sda iff vif.scl === 1'b1);
            
            ap.write(tx);
        end    
    endtask 
endclass 
`endif