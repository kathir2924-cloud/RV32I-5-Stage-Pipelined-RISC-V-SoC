`timescale 1ns/1ps

module mmio_decoder_tb;

    reg        mem_read;
    reg        mem_write;
    reg [31:0] address;
    reg [31:0] write_data;

    wire [31:0] read_data;

    wire gpio_sel;
    wire uart_tx_sel;
    wire uart_rx_sel;

    wire mmio_read;
    wire mmio_write;

    mmio_decoder dut (
        .mem_read(mem_read),
        .mem_write(mem_write),

        .address(address),
        .write_data(write_data),

        .read_data(read_data),

        .gpio_sel(gpio_sel),
        .uart_tx_sel(uart_tx_sel),
        .uart_rx_sel(uart_rx_sel),

        .mmio_read(mmio_read),
        .mmio_write(mmio_write)
    );

    task check;
        input [31:0] addr;
        input        rd;
        input        wr;
        input        expected_mmio_rd;
        input        expected_mmio_wr;
        input        expected_gpio;
        input        expected_uart_tx;
        input        expected_uart_rx;

        begin

            address   = addr;
            mem_read  = rd;
            mem_write = wr;

            #1;

            if (
                mmio_read   == expected_mmio_rd &&
                mmio_write  == expected_mmio_wr &&
                gpio_sel    == expected_gpio &&
                uart_tx_sel == expected_uart_tx &&
                uart_rx_sel == expected_uart_rx
            ) begin

                $display(
                    "PASS: ADDR=%08h RD=%b WR=%b",
                    addr, rd, wr
                );

            end
            else begin

                $display(
                    "FAIL: ADDR=%08h RD=%b WR=%b | MMIO_RD=%b MMIO_WR=%b GPIO=%b UART_TX=%b UART_RX=%b",
                    addr,
                    rd,
                    wr,
                    mmio_read,
                    mmio_write,
                    gpio_sel,
                    uart_tx_sel,
                    uart_rx_sel
                );

            end

        end

    endtask

    initial begin

        address   = 32'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        write_data = 32'b0;

        $display("==============================================");
        $display(" MMIO DECODER TEST");
        $display("==============================================");

        // GPIO write
        check(
            32'h10000000,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            1'b0
        );

        // GPIO read
        check(
            32'h10000000,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0
        );

        // UART TX write
        check(
            32'h10000004,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            1'b0
        );

        // UART RX read
        check(
            32'h10000008,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b1
        );

        // STATUS read
        check(
            32'h10000010,
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );

        // Normal RAM address
        check(
            32'h00000020,
            1'b1,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0,
            1'b0
        );

        $display("==============================================");
        $display(" MMIO DECODER TEST COMPLETE");
        $display("==============================================");

        $finish;

    end

endmodule