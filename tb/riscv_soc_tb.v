`timescale 1ns/1ps

module riscv_soc_tb;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    reg clk;
    reg rst;

    reg uart_rx;

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ============================================================
    // DUT
    // ============================================================

    riscv_soc dut (

        .clk(clk),
        .rst(rst),

        .uart_rx(uart_rx)

    );

    // ============================================================
    // TEST PROGRAM
    // ============================================================
    //
    // Program:
    //
    // 0x00 : ADDI x1, x0, 42
    // 0x04 : SW   x1, 0(x0)
    // 0x08 : LW   x2, 0(x0)
    // 0x0C : ADD  x3, x2, x1
    // 0x10 : ADDI x4, x3, 1
    // 0x14 : JAL  x0, 0
    //
    // Expected:
    //
    // x1 = 42
    // x2 = 42
    // x3 = 84
    // x4 = 85
    //
    // DATA RAM:
    //
    // mem[0] = 42
    //
    // ============================================================

    initial begin

        // ========================================================
        // INITIAL CONDITIONS
        // ========================================================

        rst     = 1'b1;
        uart_rx = 1'b0;

        // ========================================================
        // CLEAR INSTRUCTION RAM
        // ========================================================

        dut.imem_ram.mem[0] = 32'h00000000;
        dut.imem_ram.mem[1] = 32'h00000000;
        dut.imem_ram.mem[2] = 32'h00000000;
        dut.imem_ram.mem[3] = 32'h00000000;
        dut.imem_ram.mem[4] = 32'h00000000;
        dut.imem_ram.mem[5] = 32'h00000000;
        dut.imem_ram.mem[6] = 32'h00000000;
        dut.imem_ram.mem[7] = 32'h00000000;

        // ========================================================
        // LOAD PROGRAM
        // ========================================================

        // ADDI x1, x0, 42
        dut.imem_ram.mem[0] = 32'h02A00093;

        // SW x1, 0(x0)
        dut.imem_ram.mem[1] = 32'h00102023;

        // LW x2, 0(x0)
        dut.imem_ram.mem[2] = 32'h00002103;

        // ADD x3, x2, x1
        dut.imem_ram.mem[3] = 32'h001101B3;

        // ADDI x4, x3, 1
        dut.imem_ram.mem[4] = 32'h00118213;

        // JAL x0, 0
        dut.imem_ram.mem[5] = 32'h0000006F;

        // ========================================================
        // RELEASE RESET
        // ========================================================

        #20;

        rst = 1'b0;

        $display("");
        $display("==============================================");
        $display("        RISC-V SOC MEMORY TEST");
        $display("==============================================");
        $display("");

        // ========================================================
        // WAIT FOR PROGRAM EXECUTION
        // ========================================================

        #500;

        // ========================================================
        // RESULTS
        // ========================================================

        $display("");
        $display("========== SOC TEST RESULTS ==========");

        $display("x1  = 0x%08h",
                 dut.core.registers.registers[1]);

        $display("x2  = 0x%08h",
                 dut.core.registers.registers[2]);

        $display("x3  = 0x%08h",
                 dut.core.registers.registers[3]);

        $display("x4  = 0x%08h",
                 dut.core.registers.registers[4]);

        $display("RAM[0] = 0x%08h",
                 dut.dmem_ram.mem[0]);

        // ========================================================
        // CHECK x1
        // ========================================================

        if (dut.core.registers.registers[1] == 32'd42)
            $display("PASS: x1 = 42");
        else
            $display("FAIL: x1 expected 42");

        // ========================================================
        // CHECK STORE
        // ========================================================

        if (dut.dmem_ram.mem[0] == 32'd42)
            $display("PASS: External RAM received SW data");
        else
            $display("FAIL: External RAM store failed");

        // ========================================================
        // CHECK LOAD
        // ========================================================

        if (dut.core.registers.registers[2] == 32'd42)
            $display("PASS: LW loaded data from external RAM");
        else
            $display("FAIL: LW expected 42");

        // ========================================================
        // CHECK ADD
        // ========================================================

        if (dut.core.registers.registers[3] == 32'd84)
            $display("PASS: x3 = x2 + x1 = 84");
        else
            $display("FAIL: x3 expected 84");

        // ========================================================
        // CHECK ADDI
        // ========================================================

        if (dut.core.registers.registers[4] == 32'd85)
            $display("PASS: x4 = x3 + 1 = 85");
        else
            $display("FAIL: x4 expected 85");

        // ========================================================
        // FINAL RESULT
        // ========================================================

        if (
            dut.core.registers.registers[1] == 32'd42 &&
            dut.dmem_ram.mem[0]             == 32'd42 &&
            dut.core.registers.registers[2] == 32'd42 &&
            dut.core.registers.registers[3] == 32'd84 &&
            dut.core.registers.registers[4] == 32'd85
        ) begin

            $display("");
            $display("==============================================");
            $display("       RISC-V SOC MEMORY TEST PASS");
            $display("==============================================");
            $display("");

        end
        else begin

            $display("");
            $display("==============================================");
            $display("       RISC-V SOC MEMORY TEST FAIL");
            $display("==============================================");
            $display("");

        end

        $finish;

    end

endmodule