`ifndef AXI_LITE_AGENT_SV
`define AXI_LITE_AGENT_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_lite_agent extends uvm_agent;
    `uvm_component_utils(axi_lite_agent)

    uvm_sequencer #(axi_lite_seq_item) sqr;
    axi_lite_driver                    drv;
    axi_lite_monitor                   mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = axi_lite_monitor::type_id::create("mon", this);
        
        if (get_is_active() == UVM_ACTIVE) begin
            sqr = uvm_sequencer#(axi_lite_seq_item)::type_id::create("sqr", this);
            drv = axi_lite_driver::type_id::create("drv", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction
endclass 

`endif