`timescale 1ns / 1ps

module i2c_slave_top (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] tx_data,
    // output logic [7:0] rx_data,
    output logic [7:0] led,
    // output logic       busy,
    // output logic       done,
    input  logic       scl,
    inout  logic       sda,
    output logic [7:0] fnd_data,
    output logic [3:0] fnd_digit
    // input logic [7:0] sw
);

    logic [7:0] rx_data;
    // logic [7:0] tx_data;
    logic       busy;
    logic       done;

    assign led = tx_data;

    I2C_SLAVE U_I2C_SLAVE (
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .busy(busy),
        .done(done),
        .scl(scl),
        .sda(sda)
    );

    fnd_controller U_FND_CTRL (
        .clk(clk),
        .reset(reset),
        .fnd_in_data({6'b0, rx_data}),
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

endmodule


    // always_ff @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         led <= 8'h00;
    //     end else if (done) begin
    //         led <= rx_data;
    //     end
    // end