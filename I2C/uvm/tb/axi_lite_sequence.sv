`ifndef AXI_LITE_SEQUENCE_SV
`define AXI_LITE_SEQUENCE_SV

`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;


class axi_lite_base_seq extends uvm_sequence#(axi_lite_seq_item);
    `uvm_object_utils(axi_lite_base_seq)
    int num_loop = 1;

    function new(string name = "axi_lite_base_seq");
        super.new(name);
    endfunction //new()

    task do_write(bit [31:0] addr, bit [31:0] data);
        axi_lite_seq_item item = axi_lite_seq_item::type_id::create("item");
        start_item(item);
        if(!item.randomize() with {write_en == 1'b1; local::addr == addr; local::data == data;})
            `uvm_fatal(get_type_name(), "do_write() Randomize() fail!")
        finish_item(item);
        `uvm_info(get_type_name(), $sformatf("do_write() 전송 완료: addr=0x%02h wdata=0x%08h", addr, data), UVM_HIGH)
    endtask 

    task do_read(bit [31:0] addr, output bit [31:0] rdata);
        axi_lite_seq_item item = axi_lite_seq_item::type_id::create("item");
        start_item(item);
        if(!item.randomize() with {write_en == 1'b0; local::addr == addr;})
            `uvm_fatal(get_type_name(), "do_read() Randomize() fail!")
        finish_item(item);
        rdata = item.rdata;
        `uvm_info(get_type_name(), $sformatf("do_read() 전송 완료: addr=0x%02h rdata=0x%08h", addr, rdata), UVM_HIGH)
    endtask 

    virtual task body();
    endtask 
endclass 

class axi_lite_write_read_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_write_read_seq)
    bit [31:0] addr;
    bit [31:0] wdata, rdata;

    function new(string name = "axi_lite_write_read_seq");
        super.new(name);
    endfunction 

    virtual task body();
        for(int i = 0; i < num_loop; i++) begin
            addr = (i % 4) * 4; 
            wdata = $urandom();
            do_write(addr, wdata);
            do_read(addr, rdata);
        end
    endtask 
endclass 


class axi_lite_rand_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_rand_seq)

    function new(string name = "axi_lite_rand_seq");
        super.new(name);
    endfunction 

    virtual task body();
        repeat(num_loop) begin
            axi_lite_seq_item item = axi_lite_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize()) begin
                `uvm_fatal(get_type_name(), "Randomize Fail!")
            end
            finish_item(item);
        end
    endtask 
endclass 


class axi_lite_i2c_tx_seq extends axi_lite_base_seq;
    `uvm_object_utils(axi_lite_i2c_tx_seq)
    bit [31:0] rdata;

    function new(string name = "axi_lite_i2c_tx_seq"); super.new(name); endfunction

    virtual task body();
        int num_tx = 1000;

        for (int i = 0; i < num_tx; i++) begin
            bit [7:0] rand_data = $urandom(); 
            `uvm_info(get_type_name(), $sformatf("=== [%0d/%0d] I2C 랜덤 전송 시작 (DATA: 0x%02h) ===", i+1, num_tx, rand_data), UVM_NONE)

            // 1. START
            do_write(32'h00, 32'h0000_0001); do_write(32'h00, 32'h0000_0000);
            #(30us); 

            do_write(32'h04, 32'h0000_0050); 
            do_write(32'h00, 32'h0000_0002); do_write(32'h00, 32'h0000_0000);
            #(250us);

            // 3. Random DATA 전송
            do_write(32'h04, {24'h0, rand_data});
            do_write(32'h00, 32'h0000_0002); do_write(32'h00, 32'h0000_0000);
            #(250us);

            // 4. STOP
            do_write(32'h00, 32'h0000_0008); do_write(32'h00, 32'h0000_0000);
            #(50us);  

            // 5. 한 사이클 종료 확인 (Status 레지스터 0x08 읽기)
            do begin do_read(32'h08, rdata); end while (rdata[10] == 1'b1);
        end

        `uvm_info(get_type_name(), ">> Coverage Sign-off: 0x0C 레지스터 타격!", UVM_NONE)
        do_write(32'h0C, 32'h0000_1234); // 쓰기 커버리지 획득
        do_read(32'h0C, rdata);          // 읽기 커버리지 획득

        `uvm_info(get_type_name(), ">> Coverage Sign-off: 0x00 레지스터 Read 타격!", UVM_NONE)
        do_read(32'h00, rdata);          // 읽기 커버리지 획득

        `uvm_info(get_type_name(), ">> I2C READ TEST: Slave에게 데이터 요청 시작!", UVM_NONE)

        do_write(32'h00, 32'h0000_0001); do_write(32'h00, 32'h0000_0000);
        #(30us);

        do_write(32'h04, 32'h0000_0051); 
        do_write(32'h00, 32'h0000_0002); do_write(32'h00, 32'h0000_0000); 
        #(250us);

        do_write(32'h00, 32'h0000_0004); do_write(32'h00, 32'h0000_0000);
        #(250us); 
        do_read(32'h08, rdata); 
        `uvm_info(get_type_name(), $sformatf(">> [SUCCESS] Slave로부터 수신된 데이터: 0x%02h", rdata[7:0]), UVM_NONE)

        do_write(32'h00, 32'h0000_0008); do_write(32'h00, 32'h0000_0000);
        #(50us);

    endtask
endclass

`endif