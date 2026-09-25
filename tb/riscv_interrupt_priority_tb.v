`timescale 1ns/1ps

module riscv_interrupt_priority_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    // ============================================================
    // DUT
    // ============================================================

    riscv_core #(
        .UART_RX_INTERRUPT_TEST(1'b1)
    ) dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ============================================================
    // UART INITIAL STATE
    // ============================================================

    initial begin
        uart_rx = 1'b1;
    end

    // ============================================================
    // UART BYTE TRANSMITTER
    //
    // 8N1
    // 4 clocks per UART bit
    // ============================================================

    task send_uart_byte;

        input [7:0] data;
        integer i;

        begin

            // START BIT
            uart_rx = 1'b0;

            repeat (4)
                @(negedge clk);

            // DATA BITS
            for (i = 0; i < 8; i = i + 1) begin

                uart_rx = data[i];

                repeat (4)
                    @(negedge clk);

            end

            // STOP BIT
            uart_rx = 1'b1;

            repeat (4)
                @(negedge clk);

        end

    endtask

    // ============================================================
    // RESET
    // ============================================================

    initial begin

        rst = 1'b1;

        repeat (3)
            @(posedge clk);

        rst = 1'b0;

        $display("");
        $display("==============================================");
        $display(" INTERRUPT PRIORITY TEST");
        $display("==============================================");

        $display("CPU reset released");

        // Allow interrupt configuration
        repeat (15)
            @(posedge clk);

        $display("Interrupt configuration complete");

        // ========================================================
        // SEND UART BYTE
        // ========================================================

        $display("");
        $display("Sending UART byte: 0x41 ('A')");

        send_uart_byte(8'h41);

        // Give CPU time to process UART interrupt
        repeat (30)
            @(posedge clk);

        // ========================================================
        // RESULTS
        // ========================================================

        $display("");
        $display("========== INTERRUPT RESULTS ==========");

        $display("MSTATUS       = 0x%08h",
                 dut.csr_unit.mstatus);

        $display("MIE           = 0x%08h",
                 dut.csr_unit.mie);

        $display("MIP           = 0x%08h",
                 dut.csr_unit.mip);

        $display("MCAUSE        = 0x%08h",
                 dut.csr_unit.mcause);

        $display("MEPC          = 0x%08h",
                 dut.csr_unit.mepc);

        $display("x6            = 0x%08h",
                 dut.registers.registers[6]);

        $display("x8            = 0x%08h",
                 dut.registers.registers[8]);

        $display("UART IRQ latch = %b",
                 dut.uart_rx_interrupt_pending_latched);

        $display("UART IRQ       = %b",
                 dut.uart_rx_interrupt);

        $display("UART IRQ pend  = %b",
                 dut.uart_rx_interrupt_pending);

        $display("Timer pending  = %b",
                 dut.timer_interrupt_pending);

        $display("IRQ taken      = %b",
                 dut.interrupt_taken);

        $display("CSR MIP        = 0x%08h",
                 dut.csr_unit.mip);

        // ========================================================
        // CHECK UART INTERRUPT
        // ========================================================

        if (dut.registers.registers[6] == 32'h8000000B)
            $display("PASS: UART external interrupt cause");
        else
            $display("FAIL: UART interrupt cause");

        // ========================================================
        // CHECK UART DATA
        // ========================================================

        if (dut.registers.registers[8] == 32'h00000041)
            $display("PASS: UART handler received 'A'");
        else
            $display("FAIL: UART handler did not receive 'A'");

        // ========================================================
        // CHECK UART LATCH
        // ========================================================

        if (dut.uart_rx_interrupt_pending_latched == 1'b0)
            $display("PASS: UART interrupt cleared");
        else
            $display("FAIL: UART interrupt still pending");

        $display("");
        $display("==============================================");
        $display(" INTERRUPT PRIORITY TEST COMPLETE");
        $display("==============================================");

        $finish;

    end

endmodule