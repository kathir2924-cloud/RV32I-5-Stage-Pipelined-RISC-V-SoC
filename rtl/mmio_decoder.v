`timescale 1ns/1ps

module mmio_decoder (
    input  wire        mem_read,
    input  wire        mem_write,

    input  wire [31:0] address,
    input  wire [31:0] write_data,

    output reg  [31:0] read_data,

    output reg         gpio_sel,
    output reg         uart_tx_sel,
    output reg         uart_rx_sel,

    output reg         mmio_read,
    output reg         mmio_write,

    output reg         status_sel,
    output reg         control_sel
);

    // ============================================================
    // MMIO ADDRESS MAP
    // ============================================================

    localparam GPIO_ADDR    = 32'h10000000;
    localparam UART_TX_ADDR = 32'h10000004;
    localparam UART_RX_ADDR = 32'h10000008;
    localparam STATUS_ADDR  = 32'h10000010;
    localparam CONTROL_ADDR = 32'h10000014;


    // ============================================================
    // MMIO DECODER
    // ============================================================

    always @(*) begin

        // Default values
        gpio_sel     = 1'b0;
        uart_tx_sel  = 1'b0;
        uart_rx_sel  = 1'b0;

        mmio_read    = 1'b0;
        mmio_write   = 1'b0;

        read_data    = 32'b0;

        status_sel   = 1'b0;
        control_sel  = 1'b0;


        // ========================================================
        // GPIO
        // ========================================================

        if (address == GPIO_ADDR) begin

            gpio_sel = 1'b1;

            if (mem_read)
                mmio_read = 1'b1;

            if (mem_write)
                mmio_write = 1'b1;

        end


        // ========================================================
        // UART TX
        // ========================================================

        else if (address == UART_TX_ADDR) begin

            uart_tx_sel = 1'b1;

            if (mem_write)
                mmio_write = 1'b1;

        end


        // ========================================================
        // UART RX
        // ========================================================

        else if (address == UART_RX_ADDR) begin

            uart_rx_sel = 1'b1;

            if (mem_read)
                mmio_read = 1'b1;

        end


        // ========================================================
        // STATUS REGISTER
        // ========================================================

        else if (address == STATUS_ADDR) begin

            status_sel = 1'b1;

            if (mem_read)
                mmio_read = 1'b1;

        end


        // ========================================================
        // CONTROL REGISTER
        // ========================================================

        else if (address == CONTROL_ADDR) begin

            control_sel = 1'b1;

            if (mem_read)
                mmio_read = 1'b1;

            if (mem_write)
                mmio_write = 1'b1;

        end

    end

endmodule