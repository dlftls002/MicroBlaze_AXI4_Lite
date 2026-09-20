`ifndef I2C_TEST_SV
`define I2C_TEST_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_base_test extends uvm_test;
    `uvm_component_utils(i2c_base_test)
    
    i2c_env env; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = i2c_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase); 
        `uvm_info(get_type_name(), "===== I2C Bridge UVM 계층 구조 =====", UVM_MEDIUM)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask 
endclass 

class i2c_write_read_test extends i2c_base_test;
    `uvm_component_utils(i2c_write_read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_lite_write_read_seq seq;
        phase.raise_objection(this);
        
        seq = axi_lite_write_read_seq::type_id::create("seq");
        seq.num_loop = 10;
        seq.start(env.axi_agt.sqr); 
        
        phase.drop_objection(this);
    endtask 
endclass 

class i2c_rand_test extends i2c_base_test;
    `uvm_component_utils(i2c_rand_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_lite_rand_seq seq;
        phase.raise_objection(this);
        
        seq = axi_lite_rand_seq::type_id::create("seq");
        seq.num_loop = 10;
        seq.start(env.axi_agt.sqr);
        
        phase.drop_objection(this);
    endtask 
endclass 

class i2c_tx_test extends i2c_base_test;
    `uvm_component_utils(i2c_tx_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_lite_i2c_tx_seq seq;
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "=== I2C 실제 전송 시나리오 시작 ===", UVM_LOW)
        seq = axi_lite_i2c_tx_seq::type_id::create("seq");
        seq.start(env.axi_agt.sqr);
        
        #100us; 
        
        phase.drop_objection(this);
    endtask 
endclass 

`endif