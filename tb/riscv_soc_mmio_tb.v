`timescale 1ns/1ps

module riscv_soc_mmio_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    // ============================================================
    // DUT
    // ============================================================

    riscv_soc dut (
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
    // INSTRUCTION MEMORY PROGRAM
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Clear instruction memory
        // --------------------------------------------------------

        dut.imem_ram.mem[0] = 32'h00000000;
        dut.imem_ram.mem[1] = 32'h00000000;
        dut.imem_ram.mem[2] = 32'h00000000;
        dut.imem_ram.mem[3] = 32'h00000000;
        dut.imem_ram.mem[4] = 32'h00000000;
        dut.imem_ram.mem[5] = 32'h00000000;
        dut.imem_ram.mem[6] = 32'h00000000;
        dut.imem_ram.mem[7] = 32'h00000000;
        dut.imem_ram.mem[8] = 32'h00000000;
        dut.imem_ram.mem[9] = 32'h00000000;
        dut.imem_ram.mem[10] = 32'h00000000;
        dut.imem_ram.mem[11] = 32'h00000000;
        dut.imem_ram.mem[12] = 32'h00000000;
        dut.imem_ram.mem[13] = 32'h00000000;
        dut.imem_ram.mem[14] = 32'h00000000;
        dut.imem_ram.mem[15] = 32'h00000000;


        // --------------------------------------------------------
        // Program
        //
        // x5  = 0x10000000
        // x1  = 42
        //
        // GPIO:
        //     SW x1, 0(x5)
        //     LW x2, 0(x5)
        //
        // STATUS:
        //     LW x3, 0x10(x5)
        //
        // CONTROL:
        //     x1 = 1
        //     SW x1, 0x14(x5)
        //     LW x4, 0x14(x5)
        // --------------------------------------------------------

        // 0: LUI x5, 0x10000
        dut.imem_ram.mem[0] =
            32'h100002B7;

        // 4: ADDI x1, x0, 42
        dut.imem_ram.mem[1] =
            32'h02A00093;

        // 8: SW x1, 0(x5)
        dut.imem_ram.mem[2] =
            32'h0012A023;

        // 12: LW x2, 0(x5)
        dut.imem_ram.mem[3] =
            32'h0002A103;

        // 16: SW x1, 0x10(x5)
        dut.imem_ram.mem[4] =
            32'h0012A823;

        // 20: LW x3, 0x10(x5)
        dut.imem_ram.mem[5] =
            32'h0102A183;

        // 24: ADDI x1, x0, 1
        dut.imem_ram.mem[6] =
            32'h00100093;

        // 28: SW x1, 0x14(x5)
        dut.imem_ram.mem[7] =
            32'h0012AA23;

        // 32: LW x4, 0x14(x5)
        dut.imem_ram.mem[8] =
            32'h0142A203;

        // 36: Infinite loop
        dut.imem_ram.mem[9] =
            32'h0000006F;

    end


    // ============================================================
    // RESET
    // ============================================================

    initial begin

        rst = 1'b1;

        // UART idle
        uart_rx = 1'b1;

        #50;

        rst = 1'b0;

        $display("");
        $display("==============================================");
        $display("       RISC-V SOC EXTERNAL MMIO TEST");
        $display("==============================================");
        $display("");

        $display("CPU reset released");

    end


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        #3000;

        $display("");
        $display("========== SOC MMIO TEST RESULTS ==========");
        $display("");

        // --------------------------------------------------------
        // CPU registers
        // --------------------------------------------------------

        $display("x1 = 0x%08h",
                 dut.core.registers.registers[1]);

        $display("x2 = 0x%08h",
                 dut.core.registers.registers[2]);

        $display("x3 = 0x%08h",
                 dut.core.registers.registers[3]);

        $display("x4 = 0x%08h",
                 dut.core.registers.registers[4]);


        // --------------------------------------------------------
        // GPIO
        // --------------------------------------------------------

        $display("GPIO = 0x%08h",
                 dut.gpio_out);


        // --------------------------------------------------------
        // CONTROL
        // --------------------------------------------------------

        $display("UART RX IRQ ENABLE = %b",
                 dut.uart_rx_interrupt_enable);


        $display("");


        // --------------------------------------------------------
        // Checks
        // --------------------------------------------------------

        if (dut.core.registers.registers[1] == 32'd1)
            $display("PASS: CPU executed MMIO program");
        else
            $display("FAIL: CPU program execution");


        if (dut.gpio_out == 32'd42)
            $display("PASS: GPIO MMIO write reached external GPIO");
        else
            $display("FAIL: GPIO MMIO write");


        if (dut.core.registers.registers[2] == 32'd42)
            $display("PASS: GPIO MMIO read returned 42");
        else
            $display("FAIL: GPIO MMIO read");


        if (dut.uart_rx_interrupt_enable == 1'b1)
            $display("PASS: CONTROL MMIO write enabled UART RX interrupt");
        else
            $display("FAIL: CONTROL MMIO write");


        if (dut.core.registers.registers[4] == 32'd1)
            $display("PASS: CONTROL MMIO read returned 1");
        else
            $display("FAIL: CONTROL MMIO read");


        $display("");
        $display("==============================================");
        $display("       RISC-V SOC EXTERNAL MMIO TEST");
        $display("==============================================");
        $display("");


        $finish;

    end

endmodule