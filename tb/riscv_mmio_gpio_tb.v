`timescale 1ns/1ps

module riscv_mmio_gpio_tb;

    reg clk;
    reg rst;

    always #5 clk = ~clk;

    // ============================================================
    // DUT
    // ============================================================

    riscv_core #(
        .CSR_TEST(1'b0),
        .TRAP_TEST(1'b0),
        .TIMER_TEST(1'b0),
        .MMIO_TEST(1'b1)
    ) dut (
        .clk(clk),
        .rst(rst)
    );

    // ============================================================
    // TEST
    // ============================================================

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        $display("==============================================");
        $display(" CPU MMIO GPIO TEST");
        $display("==============================================");

        // Reset
        #20;
        rst = 1'b0;

        // Allow CPU to execute
        #300;

        $display("");
        $display("========== MMIO GPIO RESULTS ==========");

        // --------------------------------------------------------
        // Check GPIO peripheral
        // --------------------------------------------------------

        if (dut.gpio_out == 32'h12345678)
            $display(
                "PASS: GPIO WRITE = 0x%08h",
                dut.gpio_out
            );
        else
            $display(
                "FAIL: GPIO WRITE = 0x%08h",
                dut.gpio_out
            );

        // --------------------------------------------------------
        // Check register x3
        // --------------------------------------------------------

        if (dut.registers.registers[3] == 32'h12345678)
            $display(
                "PASS: GPIO READ -> x3 = 0x%08h",
                dut.registers.registers[3]
            );
        else
            $display(
                "FAIL: GPIO READ -> x3 = 0x%08h",
                dut.registers.registers[3]
            );

        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------

        if (
            dut.gpio_out == 32'h12345678 &&
            dut.registers.registers[3] == 32'h12345678
        ) begin

            $display("");
            $display("==============================================");
            $display(" CPU MMIO GPIO TEST PASS");
            $display("==============================================");

        end
        else begin

            $display("");
            $display("==============================================");
            $display(" CPU MMIO GPIO TEST FAIL");
            $display("==============================================");

        end

        $finish;

    end

endmodule