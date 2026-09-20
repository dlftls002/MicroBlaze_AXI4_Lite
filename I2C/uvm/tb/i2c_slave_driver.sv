`ifndef I2C_SLAVE_DRIVER_SV
`define I2C_SLAVE_DRIVER_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_slave_driver extends uvm_driver#(uvm_sequence_item);
    `uvm_component_utils(i2c_slave_driver) 
    virtual i2c_if vif;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this,"","vif",vif)) `uvm_fatal("NO_VIF", "vif error")
    endfunction

   virtual task run_phase(uvm_phase phase);
        vif.sda_oe <= 0;
        vif.sda_out <= 0;
        
        forever begin
            bit [7:0] addr_rw;
            bit [7:0] slave_tx_data = 8'h05; 
            @(negedge vif.sda iff vif.scl === 1'b1);
            
            fork
                begin : i2c_transaction
                    for(int i=0; i<8; i++) begin
                        @(posedge vif.scl);
                        addr_rw[7-i] = vif.sda;
                    end

                    @(negedge vif.scl);
                    vif.sda_out <= 0; vif.sda_oe <= 1'b1;
                    @(negedge vif.scl);
                    vif.sda_oe <= 0;

                    if (addr_rw[0] == 1'b1) begin
                      
                        for(int i=0; i<8; i++) begin
                            vif.sda_out <= slave_tx_data[7-i];
                            vif.sda_oe <= 1'b1; 
                            @(negedge vif.scl);
                        end
                        vif.sda_oe <= 0; 
                        @(negedge vif.scl); 
                    end 
                    else begin
                        forever begin
                            repeat(8) @(posedge vif.scl);
                            @(negedge vif.scl);
                            vif.sda_out <= 0; vif.sda_oe <= 1'b1;
                            @(negedge vif.scl);
                            vif.sda_oe <= 0;
                        end
                    end
                end
                begin : wait_stop
                    @(posedge vif.sda iff vif.scl === 1'b1); 
                end
            join_any
            
            disable fork;
            vif.sda_oe <= 0;
        end
    endtask
endclass
`endif