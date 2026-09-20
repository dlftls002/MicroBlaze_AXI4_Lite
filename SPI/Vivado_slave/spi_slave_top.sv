`timescale 1ns / 1ps

module spi_slave_top (
    input logic clk,
    input logic reset,
    input logic [7:0] tx_data,
    // output logic [7:0] rx_data,
    output logic [7:0] led,
    // output logic done,
    input logic sclk,
    input logic mosi,
    output logic miso,
    input logic cs_n,
    // output logic busy
    output logic [3:0] fnd_digit,
    output logic [7:0] fnd_data
);

    logic done;
    logic busy;
    // logic [7:0] tx_data;
    logic [7:0] rx_data;

    assign led = tx_data;

    spi_slave u_spi_slave (
        .clk    (clk),
        .reset  (reset),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .done   (done),
        .sclk   (sclk),
        .mosi   (mosi),
        .miso   (miso),
        .cs_n   (cs_n),
        .busy   (busy)
    );

    // btn_debounce u_bd (
    //     .clk  (clk),
    //     .reset(reset),
    //     .i_btn(btn_start),
    //     .o_btn(o_btn)
    // );

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .reset(reset),
        .fnd_in_data({6'b0, rx_data}),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

endmodule
