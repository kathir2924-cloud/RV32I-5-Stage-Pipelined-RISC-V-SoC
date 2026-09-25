`timescale 1ns/1ps

module riscv_uart_irq_control_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    riscv_core #(
        .UART_IRQ_CONTROL_TEST(1)
    ) dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx)
    );

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        rst = 1'b1;
        uart_rx = 1'b1;

        // Reset
        repeat (3) @(posedge clk);
        rst = 1'b0;

        // Allow CONTROL = 1 store to reach MMIO
        repeat (8) @(posedge clk);

        if (dut.uart_rx_interrupt_enable !== 1'b1) begin
            $display("FAIL: CONTROL register did not enable UART RX interrupt");
            $display("uart_rx_interrupt_enable = %b",
                     dut.uart_rx_interrupt_enable);
            $finish;
        end
        else begin
            $display("PASS: CONTROL register enabled UART RX interrupt");
        end

        // Allow CONTROL = 0 store to reach MMIO
        repeat (8) @(posedge clk);

        if (dut.uart_rx_interrupt_enable !== 1'b0) begin
            $display("FAIL: CONTROL register did not disable UART RX interrupt");
            $display("uart_rx_interrupt_enable = %b",
                     dut.uart_rx_interrupt_enable);
            $finish;
        end
        else begin
            $display("PASS: CONTROL register disabled UART RX interrupt");
        end

        $display("");
        $display("==========================================");
        $display(" UART RX CONTROL REGISTER TEST PASS");
        $display("==========================================");

        $finish;
    end

endmodule