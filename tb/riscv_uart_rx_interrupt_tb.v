`timescale 1ns/1ps

module riscv_uart_rx_interrupt_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    riscv_core #(
        .UART_RX_INTERRUPT_TEST(1)
    ) dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx)
    );

    always #5 clk = ~clk;

    // ------------------------------------------------
    // UART bit transmission
    // CLKS_PER_BIT = 4
    // ------------------------------------------------

    task send_bit;
        input bit_value;
        begin
            uart_rx = bit_value;
            repeat (4) @(negedge clk);
        end
    endtask

    task send_uart_byte;
        input [7:0] data;
        integer i;

        begin

            // Start bit
            send_bit(1'b0);

            // Data bits LSB first
            for (i = 0; i < 8; i = i + 1)
                send_bit(data[i]);

            // Stop bit
            send_bit(1'b1);

        end
    endtask

    initial begin

        clk = 1'b0;
        rst = 1'b1;
        uart_rx = 1'b1;

        $display("");
        $display("==============================================");
        $display("     UART RX MACHINE INTERRUPT TEST");
        $display("==============================================");

        // Reset
        repeat (3) @(posedge clk);
        rst = 1'b0;

        $display("CPU reset released");

        // Give CPU time to configure:
        // MTVEC
        // MSTATUS.MIE
        // MIE[11]
        // CONTROL bit 0
        repeat (15) @(posedge clk);

        $display("UART RX interrupt configuration complete");

        // Send ASCII A
        $display("Sending UART byte: 0x41 ('A')");
        send_uart_byte(8'h41);

        // Allow interrupt and handler to execute
        repeat (30) @(posedge clk);

        $display("");
        $display("========== UART INTERRUPT RESULTS ==========");

        $display("MSTATUS = 0x%08h", dut.csr_unit.mstatus);
        $display("MIE     = 0x%08h", dut.csr_unit.mie);
        $display("MIP     = 0x%08h", dut.csr_unit.mip);
        $display("MCAUSE  = 0x%08h", dut.csr_unit.mcause);
        $display("MEPC    = 0x%08h", dut.csr_unit.mepc);
        $display("x6      = 0x%08h", dut.registers.registers[6]);
        $display("x8      = 0x%08h", dut.registers.registers[8]);
        $display("IRQ latch = %b",
                 dut.uart_rx_interrupt_pending_latched);

        // ------------------------------------------------
        // Checks
        // ------------------------------------------------
$display("PC             = 0x%08h", dut.pc);
$display("UART IRQ       = %b", dut.uart_rx_interrupt);
$display("UART IRQ pend  = %b", dut.uart_rx_interrupt_pending);
$display("IRQ taken      = %b", dut.interrupt_taken);
$display("Timer pending  = %b", dut.timer_interrupt_pending);
$display("CSR MIP        = 0x%08h", dut.csr_unit.mip);
        if (dut.csr_unit.mcause !== 32'h8000000B) begin
            $display("FAIL: MCAUSE is not machine external interrupt");
            $display("Expected = 0x8000000B");
            $display("Actual   = 0x%08h", dut.csr_unit.mcause);
            $finish;
        end
        else begin
            $display("PASS: MCAUSE = 0x8000000B");
        end

        if (dut.registers.registers[6] !== 32'h8000000B) begin
            $display("FAIL: Interrupt handler did not read MCAUSE");
            $finish;
        end
        else begin
            $display("PASS: Handler captured MCAUSE");
        end

        if (dut.registers.registers[8] !== 32'h00000041) begin
            $display("FAIL: Interrupt handler did not receive UART byte");
            $display("Expected = 0x00000041");
            $display("Actual   = 0x%08h",
                     dut.registers.registers[8]);
            $finish;
        end
        else begin
            $display("PASS: Handler received UART byte 'A'");
        end

        if (dut.uart_rx_interrupt_pending_latched !== 1'b0) begin
            $display("FAIL: UART RX interrupt pending did not clear");
            $finish;
        end
        else begin
            $display("PASS: UART RX interrupt pending cleared");
        end


$display("");
$display("========== INTERNAL IRQ DEBUG ==========");
$display("UART data_valid       = %b", dut.uart_rx_data_valid);
$display("UART IRQ enable       = %b", dut.uart_rx_interrupt_enable);
$display("UART IRQ latch        = %b", dut.uart_rx_interrupt_pending_latched);
$display("UART IRQ              = %b", dut.uart_rx_interrupt);
$display("CSR UART IRQ pending  = %b", dut.uart_rx_interrupt_pending);
$display("CSR MIP               = 0x%08h", dut.csr_unit.mip);
$display("CSR MIE               = 0x%08h", dut.csr_unit.mie);
$display("CSR MSTATUS           = 0x%08h", dut.csr_unit.mstatus);
$display("INTERRUPT TAKEN       = %b", dut.interrupt_taken);
$display("INTERRUPT CAUSE       = 0x%08h", dut.interrupt_cause);
$display("========================================");
        $display("");
        $display("==============================================");
        $display(" UART RX MACHINE INTERRUPT TEST PASS");
        $display("==============================================");

        $finish;
    end

endmodule