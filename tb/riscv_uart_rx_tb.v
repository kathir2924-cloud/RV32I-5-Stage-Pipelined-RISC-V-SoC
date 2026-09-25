`timescale 1ns/1ps

module riscv_uart_rx_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    always #5 clk = ~clk;

    riscv_core #(
        .CSR_TEST(1'b0),
        .TRAP_TEST(1'b0),
        .TIMER_TEST(1'b0),
        .MMIO_TEST(1'b0),
        .UART_TX_TEST(1'b0),
        .UART_RX_TEST(1'b1)
    ) dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx)
    );

    // ------------------------------------------------
    // Send one UART bit
    // ------------------------------------------------
    task send_bit;
    input bit_value;
    begin
        uart_rx = bit_value;
        repeat (4) @(negedge clk);
    end
endtask

    // ------------------------------------------------
    // Send one UART byte, 8-N-1
    // ------------------------------------------------
    task send_byte;
        input [7:0] data;
        integer i;

        begin

            // Start bit
            send_bit(1'b0);

            // 8 data bits, LSB first
            for (i = 0; i < 8; i = i + 1)
                send_bit(data[i]);

            // Stop bit
            send_bit(1'b1);

        end
    endtask

    // ------------------------------------------------
    // Main test
    // ------------------------------------------------
    initial begin

        clk     = 1'b0;
        rst     = 1'b1;
        uart_rx = 1'b1;

        $display("==============================================");
        $display("       CPU MMIO UART RX TEST");
        $display("==============================================");

        // Reset CPU
        #20;
rst = 1'b0;

$display("CPU reset released");

// Give UART RX several idle clock cycles
repeat (10) @(posedge clk);

$display("UART RX ready");
$display("Sending UART byte: 0x41 ('A')");


$display("Before transmission:");
$display("  uart_rx input = %b", uart_rx);
$display("  RX receiving  = %b", dut.uart_rx_peripheral.receiving);
$display("  RX data       = 0x%02h", dut.uart_rx_peripheral.rx_data);
        // Send A
        send_byte(8'h41);

        $display("After transmission:");
$display("  uart_rx input = %b", uart_rx);
$display("  RX receiving  = %b", dut.uart_rx_peripheral.receiving);
$display("  RX data       = 0x%02h", dut.uart_rx_peripheral.rx_data);
$display("  RX valid      = %b", dut.uart_rx_data_valid);

        $display("UART transmission finished");
        $display("RX data = 0x%08h", dut.uart_rx_read_data);
        $display("RX valid = %b", dut.uart_rx_data_valid);

        // Give CPU enough time to execute LW
        repeat (30) @(posedge clk);

        $display("");
        $display("========== UART RX RESULTS ==========");

        $display("x1 = 0x%08h", dut.registers.registers[1]);
        $display("x3 = 0x%08h", dut.registers.registers[3]);
        $display("RX data = 0x%08h", dut.uart_rx_read_data);

        if (dut.registers.registers[3] == 32'h00000041) begin

            $display("");
            $display("PASS: CPU received ASCII 'A'");
            $display("PASS: x3 = 0x00000041");

        end
        else begin

            $display("");
            $display("FAIL: CPU received 0x%08h",
                     dut.registers.registers[3]);

        end

        $display("");
        $display("==============================================");
        $display("       CPU MMIO UART RX TEST COMPLETE");
        $display("==============================================");

        $finish;

    end

    // ------------------------------------------------
    // Hard simulation timeout
    // ------------------------------------------------
    initial begin

        #5000;

        $display("");
        $display("==============================================");
        $display("       UART RX TEST TIMEOUT");
        $display("==============================================");

        $display("PC       = 0x%08h", dut.pc);
        $display("x1       = 0x%08h", dut.registers.registers[1]);
        $display("x3       = 0x%08h", dut.registers.registers[3]);
        $display("RX data  = 0x%08h", dut.uart_rx_read_data);
        $display("RX valid = %b", dut.uart_rx_data_valid);

        $finish;

    end

endmodule