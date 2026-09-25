`timescale 1ns/1ps

module riscv_timer_interrupt_tb;

    reg clk;
    reg rst;

    // ============================================================
    // CLOCK
    // ============================================================

    always #5 clk = ~clk;

    // ============================================================
    // DUT
    // ============================================================

    riscv_core #(
        .CSR_TEST(1'b0),
        .TRAP_TEST(1'b0),
        .TIMER_TEST(1'b1)
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
        $display(" CPU MACHINE TIMER INTERRUPT TEST");
        $display("==============================================");

        // Reset
        #20;
        rst = 1'b0;

        // Allow CPU to execute program and timer interrupt
        #1000;

        $display("");
$display("========== TIMER DEBUG ==========");

$display("timer_interrupt        = %b",
         dut.timer_interrupt);

$display("timer_interrupt_pending = %b",
         dut.timer_interrupt_pending);

$display("interrupt_taken        = %b",
         dut.interrupt_taken);

$display("MSTATUS                = 0x%08h",
         dut.csr_unit.mstatus);

$display("MIE                    = 0x%08h",
         dut.csr_unit.mie);

$display("MIP                    = 0x%08h",
         dut.csr_unit.mip);

$display("MTVEC                  = 0x%08h",
         dut.mtvec_value);

$display("MCAUSE                 = 0x%08h",
         dut.csr_unit.mcause);

$display("MEPC                   = 0x%08h",
         dut.csr_unit.mepc);

$display("PC                     = 0x%08h",
         dut.pc);

$display("EX_PC                  = 0x%08h",
         dut.ex_pc);

$display("EX_VALID               = %b",
         dut.ex_valid);

$display("=================================");

        $display("");
        $display("==============================================");
        $display(" TIMER INTERRUPT TEST RESULTS");
        $display("==============================================");

        // --------------------------------------------------------
        // Check MTVEC
        // --------------------------------------------------------

        if (dut.mtvec_value == 32'h00000100)
            $display("PASS: MTVEC = 0x%08h", dut.mtvec_value);
        else
            $display("FAIL: MTVEC = 0x%08h", dut.mtvec_value);

        // --------------------------------------------------------
        // Check MCAUSE
        // --------------------------------------------------------

        if (dut.csr_unit.mcause == 32'h80000007)
            $display("PASS: MCAUSE = 0x%08h", dut.csr_unit.mcause);
        else
            $display("FAIL: MCAUSE = 0x%08h", dut.csr_unit.mcause);

        // --------------------------------------------------------
        // Check handler captured MCAUSE
        // x5 should contain 0x80000007
        // --------------------------------------------------------

        if (dut.registers.registers[5] == 32'h80000007)
            $display("PASS: Handler captured MCAUSE in x5");
        else
            $display(
                "FAIL: x5 = 0x%08h",
                dut.registers.registers[5]
            );

        // --------------------------------------------------------
        // Check handler captured MEPC
        // --------------------------------------------------------

        if (dut.registers.registers[6] != 32'b0)
            $display(
                "PASS: Handler captured MEPC = 0x%08h",
                dut.registers.registers[6]
            );
        else
            $display("FAIL: Handler did not capture MEPC");

        // --------------------------------------------------------
        // Final status
        // --------------------------------------------------------

        if (
            dut.mtvec_value == 32'h00000100 &&
            dut.csr_unit.mcause == 32'h80000007 &&
            dut.registers.registers[5] == 32'h80000007 &&
            dut.registers.registers[6] != 32'b0
        ) begin

            $display("");
            $display("==============================================");
            $display(" MACHINE TIMER INTERRUPT TEST PASS");
            $display("==============================================");

        end
        else begin

            $display("");
            $display("==============================================");
            $display(" MACHINE TIMER INTERRUPT TEST FAIL");
            $display("==============================================");

        end

        $finish;

    end

endmodule