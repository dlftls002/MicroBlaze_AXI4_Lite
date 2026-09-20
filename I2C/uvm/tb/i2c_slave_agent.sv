`ifndef I2C_SLAVE_AGENT_SV
`define I2C_SLAVE_AGENT_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_slave_agent extends uvm_agent;
    `uvm_component_utils(i2c_slave_agent)

    i2c_slave_driver  drv;
    i2c_monitor       mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        mon = i2c_monitor::type_id::create("mon", this);
        
        if (get_is_active() == UVM_ACTIVE) begin
            drv = i2c_slave_driver::type_id::create("drv", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
endclass 

`endif