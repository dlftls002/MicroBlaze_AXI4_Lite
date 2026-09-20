`ifndef I2C_SCOREBOARD_SV
`define I2C_SCOREBOARD_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_i2c)

class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    uvm_analysis_imp_axi #(axi_lite_seq_item, i2c_scoreboard) axi_imp;
    uvm_analysis_imp_i2c #(i2c_seq_item,      i2c_scoreboard) i2c_imp;

    logic [7:0] expected_i2c_q[$]; 
    int num_axi_writes = 0;
    int num_matches    = 0;
    int num_errors     = 0;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_imp = new("axi_imp", this);
        i2c_imp = new("i2c_imp", this);
    endfunction

    virtual function void write_axi(axi_lite_seq_item tx);
        if (tx.write_en && tx.addr == 32'h04) begin
            expected_i2c_q.push_back(tx.data[7:0]);
            num_axi_writes++;
        end
    endfunction 

    virtual function void write_i2c(i2c_seq_item tx);
        logic [7:0] exp_addr, exp_data, actual_addr;

        actual_addr = {tx.slave_addr, tx.is_read};

        if (expected_i2c_q.size() >= 2) begin
            exp_addr = expected_i2c_q.pop_front();
            exp_data = expected_i2c_q.pop_front();

            `uvm_info(get_type_name(), $sformatf("[MASTER] 0x%02h -> [SLAVE] 0x%02h", exp_data, tx.data), UVM_NONE)

            if (exp_addr === actual_addr && exp_data === tx.data) begin
                num_matches++;
                `uvm_info(get_type_name(), $sformatf("Match!! tx_data=0x%02h, rx_data=0x%02h", exp_data, tx.data), UVM_NONE)
            end else begin
                num_errors++;
                `uvm_error(get_type_name(), $sformatf("Mismatch! exp_data=0x%02h, rx_data=0x%02h", exp_data, tx.data))
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "===== Scoreboard Summary =====", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("Total transaction: %0d", num_matches + num_errors), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("Pass: %0d", num_matches), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("Fail: %0d", num_errors), UVM_NONE)
        if(num_errors == 0 && num_matches > 0)
            `uvm_info(get_type_name(), $sformatf("TEST PASSED: %0d all matches detected", num_matches), UVM_NONE)
    endfunction
endclass 
`endif