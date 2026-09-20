`ifndef I2C_SEQ_ITEM_SV
`define I2C_SEQ_ITEM_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class i2c_seq_item extends uvm_sequence_item;
    
    logic [6:0] slave_addr; // 7비트 슬레이브 주소
    logic       is_read;    // 1: Read, 0: Write
    logic [7:0] data;       // 8비트 데이터

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(slave_addr, UVM_ALL_ON)
        `uvm_field_int(is_read,    UVM_ALL_ON)
        `uvm_field_int(data,       UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "i2c_seq_item"); 
        super.new(name); 
    endfunction
    
    function string convert2string();
        string op = is_read ? "READ " : "WRITE";
        return $sformatf("I2C %s | SLV_ADDR: 0x%0h | DATA: 0x%02h", op, slave_addr, data);
    endfunction

endclass

`endif