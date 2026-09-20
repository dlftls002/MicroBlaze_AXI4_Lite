`ifndef I2C_COVERAGE_SV
`define I2C_COVERAGE_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_coverage extends uvm_subscriber #(axi_lite_seq_item);
    `uvm_component_utils(i2c_coverage)

    axi_lite_seq_item tx;

    covergroup cg_axi_reg;
        cp_addr: coverpoint tx.addr {
            bins ctrl_reg   = {32'h00};
            bins tx_reg     = {32'h04};
            bins status_reg = {32'h08};
            bins etc_reg    = {32'h0C};
        }
        
        cp_rw: coverpoint tx.write_en {
            bins read  = {0};
            bins write = {1};
        }
        
        cross cp_addr, cp_rw {
            ignore_bins ignore_status_write = binsof(cp_addr.status_reg) && binsof(cp_rw.write);
            
            ignore_bins ignore_tx_read = binsof(cp_addr.tx_reg) && binsof(cp_rw.read);
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_axi_reg = new(); 
    endfunction

    virtual function void write(axi_lite_seq_item t);
        tx = t;
        cg_axi_reg.sample(); 
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("===== I2C Test Coverage: %.1f%% =====", cg_axi_reg.get_coverage()), UVM_NONE)
    endfunction
endclass

`endif