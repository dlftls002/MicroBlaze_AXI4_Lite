`ifndef I2C_ENV_SV
`define I2C_ENV_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_env extends uvm_env;
    `uvm_component_utils(i2c_env)
    
    axi_lite_agent   axi_agt;
    i2c_slave_agent  i2c_agt;
    
    i2c_scoreboard   scb;
    i2c_coverage     cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        axi_agt = axi_lite_agent::type_id::create("axi_agt", this);
        i2c_agt = i2c_slave_agent::type_id::create("i2c_agt", this);
        scb     = i2c_scoreboard::type_id::create("scb", this);
        cov     = i2c_coverage::type_id::create("cov", this); 
    endfunction

    virtual function void connect_phase(uvm_phase phase); 
        super.connect_phase(phase);
        
        axi_agt.mon.ap.connect(scb.axi_imp);
        i2c_agt.mon.ap.connect(scb.i2c_imp);

        axi_agt.mon.ap.connect(cov.analysis_export); 
    endfunction

endclass 

`endif