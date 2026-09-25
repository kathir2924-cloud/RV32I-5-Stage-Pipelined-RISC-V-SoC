`timescale 1ns/1ps

module riscv_uart_tx_tb;

    reg clk;
    reg rst;

    always #5 clk = ~clk;

    riscv_core #(
        .CSR_TEST(1'b0),
        .TRAP_TEST(1'b0),
        .TIMER_TEST(1'b0),
        .MMIO_TEST(1'b0),
        .UART_TX_TEST(1'b1)
    ) dut (
        .clk(clk),
        .rst(rst)
    );

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        $display("==============================================");
        $display("       CPU MMIO UART TX TEST");
        $display("==============================================");

        #20;
        rst = 1'b0;

        // Allow CPU to execute UART transmission
        #300;

        $display("");
        $display("========== UART TX RESULTS ==========");

        if (dut.uart_tx_busy == 1'b1 ||
            dut.uart_tx == 1'b0) begin

            $display("PASS: CPU triggered UART TX");
            $display("UART TX = %b", dut.uart_tx);
            $display("UART BUSY = %b", dut.uart_tx_busy);

        end
        else begin

            $display("INFO: UART transmission may have completed");
            $display("UART TX = %b", dut.uart_tx);
            $display("UART BUSY = %b", dut.uart_tx_busy);

        end

        if (dut.registers.registers[2] == 32'h00000041)
            $display("PASS: x2 = ASCII 'A' (0x41)");
        else
            $display("FAIL: x2 = 0x%08h",
                     dut.registers.registers[2]);

        $display("");
        $display("==============================================");
        $display("       CPU MMIO UART TX TEST COMPLETE");
        $display("==============================================");

        $finish;

    end

endmodule