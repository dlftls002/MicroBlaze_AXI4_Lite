`timescale 1ns / 1ps

module spi_slave (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       done,
    input  logic       sclk,
    input  logic       mosi,
    output logic       miso,
    input  logic       cs_n,
    output logic       busy
);

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } spi_state_e;

    spi_state_e state;
    logic [7:0] tx_shift_reg;
    logic [7:0] rx_shift_reg;
    logic [2:0] bit_cnt;

    logic [1:0] sclk_sync;
    logic [1:0] cs_n_sync;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_sync <= 2'b00;
            cs_n_sync <= 2'b11;
        end else begin
            sclk_sync <= {sclk_sync[0], sclk};
            cs_n_sync <= {cs_n_sync[0], cs_n};
        end
    end

    wire sclk_rising = (sclk_sync == 2'b01);
    wire sclk_falling = (sclk_sync == 2'b10);
    wire cs_n_falling = (cs_n_sync == 2'b10);
    wire cs_n_rising = (cs_n_sync == 2'b01);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            miso <= 1'b1;
            rx_data <= 0;
            busy <= 1'b0;
            done <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt <= 0;
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    miso    <= 1'b1;
                    busy    <= 1'b0;
                    bit_cnt <= 0;

                    if (cs_n_falling) begin
                        tx_shift_reg <= tx_data;
                        state        <= START;
                        busy         <= 1'b1;

                    end
                end

                START: begin
                    miso         <= tx_shift_reg[7];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    state        <= DATA;
                end

                DATA: begin
                    if (cs_n_rising) begin
                        state <= IDLE;
                    end else if (sclk_rising) begin
                        rx_shift_reg <= {rx_shift_reg[6:0], mosi};
                    end else if (sclk_falling) begin
                        if (bit_cnt < 7) begin
                            miso         <= tx_shift_reg[7];
                            tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            bit_cnt      <= bit_cnt + 1;
                        end else begin
                            state   <= STOP;
                            rx_data <= rx_shift_reg;
                        end
                    end
                end

                STOP: begin
                    miso  <= 1'b1;
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

