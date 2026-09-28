`timescale 1ns/1ps

module riscv_performance_counter_tb;

    reg clk;
    reg rst;

    // ============================================================
    // DUT
    // ============================================================

    riscv_core dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(1'b1),
        .imem_addr(),
        .imem_rdata(32'b0),
        .dmem_read(),
        .dmem_write(),
        .dmem_addr(),
        .dmem_wdata(),
        .dmem_rdata(32'b0),
        .mmio_read(),
        .mmio_write(),
        .mmio_addr(),
        .mmio_wdata(),
        .mmio_rdata(32'b0),
        .uart_rx_irq(1'b0)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // TEST
    // ============================================================

    initial begin

        $display("");
        $display("==============================================");
        $display("   CPU PERFORMANCE COUNTER INTEGRATION TEST");
        $display("==============================================");

        rst = 1'b1;

        #30;

        rst = 1'b0;

        $display("CPU reset released");

        // --------------------------------------------------------
        // Run the processor
        // --------------------------------------------------------

        #1000;

        // --------------------------------------------------------
        // Display actual CPU counters
        // --------------------------------------------------------

        $display("");
        $display("========== CPU COUNTER RESULTS ==========");

        $display("Cycle Count          = %0d",
                 dut.cycle_count);

        $display("Instructions Retired = %0d",
                 dut.instret_count);

        $display("Stall Cycles          = %0d",
                 dut.stall_count);

        $display("");

        // --------------------------------------------------------
        // Basic validation
        // --------------------------------------------------------

        if (dut.cycle_count > 0)
            $display("PASS: CPU cycle counter increments");
        else
            $display("FAIL: CPU cycle counter is zero");

        if (dut.instret_count > 0)
            $display("PASS: CPU instruction-retired counter increments");
        else
            $display("FAIL: CPU instruction-retired counter is zero");

        if (dut.cycle_count >= dut.instret_count)
            $display("PASS: Cycle count >= instruction count");
        else
            $display("FAIL: Invalid counter relationship");

        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------

        if ((dut.cycle_count > 0) &&
            (dut.instret_count > 0) &&
            (dut.cycle_count >= dut.instret_count)) begin

            $display("");
            $display("==============================================");
            $display(" CPU PERFORMANCE COUNTER INTEGRATION PASS");
            $display("==============================================");

        end
        else begin

            $display("");
            $display("==============================================");
            $display(" CPU PERFORMANCE COUNTER INTEGRATION FAIL");
            $display("==============================================");

        end

        $finish;
    end

endmodule