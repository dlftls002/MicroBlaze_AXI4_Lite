`ifndef AXI_LITE_SEQ_ITEM_SV
`define AXI_LITE_SEQ_ITEM_SV

`timescale 1ns / 1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_lite_seq_item extends uvm_sequence_item;
    
    rand logic [31:0] addr;      // AXI 주소
    rand logic        write_en;  // 1: Write, 0: Read
    rand logic [31:0] data;      // 쓰기용 데이터 (Master -> Slave)
    logic      [31:0] rdata;     // 읽기용 데이터 (Slave -> Master)
    logic      [1:0]  resp;      // 응답 상태 (BRESP, RRESP 저장용)

    constraint c_addr_align { addr % 4 == 0; }
    constraint c_addr_range { addr inside {32'h0, 32'h4, 32'h8, 32'hC}; }
    
    `uvm_object_utils_begin(axi_lite_seq_item)
        `uvm_field_int(addr,     UVM_ALL_ON)
        `uvm_field_int(write_en, UVM_ALL_ON)
        `uvm_field_int(data,     UVM_ALL_ON)
        `uvm_field_int(rdata,    UVM_ALL_ON)
        `uvm_field_int(resp,     UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_lite_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        string op = write_en ? "WRITE" : "READ ";
        if (write_en)
            return $sformatf("%s | ADDR: 0x%02h | WDATA: 0x%08h", op, addr, data);
        else
            return $sformatf("%s | ADDR: 0x%02h | RDATA: 0x%08h", op, addr, rdata);
    endfunction

endclass

`endif