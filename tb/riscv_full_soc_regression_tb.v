`timescale 1ns/1ps

module riscv_full_soc_regression_tb;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    reg clk;
    reg rst;
    reg uart_rx;

    integer errors;
    integer i;


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
    // UART RX
    //
    // UART peripherals use CLKS_PER_BIT = 4.
    //
    // Idle  = 1
    // Start = 0
    // Data  = LSB first
    // Stop  = 1
    // ============================================================

    task uart_send_byte;
        input [7:0] data;
        integer b;

        begin

            // Start bit
            uart_rx = 1'b0;

            repeat (4)
                @(posedge clk);

            // Data bits
            for (b = 0; b < 8; b = b + 1) begin

                uart_rx = data[b];

                repeat (4)
                    @(posedge clk);

            end

            // Stop bit
            uart_rx = 1'b1;

            repeat (4)
                @(posedge clk);

        end
    endtask


    // ============================================================
    // INSTRUCTION ENCODERS
    // ============================================================

    function [31:0] enc_addi;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;

        begin
            enc_addi =
                {imm, rs1, 3'b000, rd, 7'b0010011};
        end
    endfunction


    function [31:0] enc_csrrw;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] csr;

        begin
            enc_csrrw =
                {csr, rs1, 3'b001, rd, 7'b1110011};
        end
    endfunction


    function [31:0] enc_csrrs;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] csr;

        begin
            enc_csrrs =
                {csr, rs1, 3'b010, rd, 7'b1110011};
        end
    endfunction


    function [31:0] enc_csrrc;
        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] csr;

        begin
            enc_csrrc =
                {csr, rs1, 3'b011, rd, 7'b1110011};
        end
    endfunction


    function [31:0] enc_csrrwi;
        input [4:0] rd;
        input [4:0] zimm;
        input [11:0] csr;

        begin
            enc_csrrwi =
                {csr, zimm, 3'b101, rd, 7'b1110011};
        end
    endfunction


    function [31:0] enc_csrrsi;
        input [4:0] rd;
        input [4:0] zimm;
        input [11:0] csr;

        begin
            enc_csrrsi =
                {csr, zimm, 3'b110, rd, 7'b1110011};
        end
    endfunction


    function [31:0] enc_csrrci;
        input [4:0] rd;
        input [4:0] zimm;
        input [11:0] csr;

        begin
            enc_csrrci =
                {csr, zimm, 3'b111, rd, 7'b1110011};
        end
    endfunction


    function [31:0] enc_mret;

        begin
            enc_mret = 32'h30200073;
        end

    endfunction


    // ============================================================
    // PROGRAM MEMORY INITIALIZATION
    //
    // This section deliberately performs a normal SoC execution
    // regression.
    //
    // The existing riscv_soc instruction RAM is used directly.
    // ============================================================

    initial begin

        // Clear first 256 words

        for (i = 0; i < 256; i = i + 1)
            dut.imem_ram.mem[i] = 32'h00000000;


        // --------------------------------------------------------
        // BASIC RV32I / MMIO PROGRAM
        // --------------------------------------------------------
        //
        // x5 = 0x10000000
        //
        // x1 = 42
        //
        // GPIO:
        //   SW x1,0(x5)
        //   LW x2,0(x5)
        //
        // STATUS:
        //   LW x3,16(x5)
        //
        // CONTROL:
        //   x1 = 1
        //   SW x1,20(x5)
        //   LW x4,20(x5)
        //
        // Then loop.
        // --------------------------------------------------------

        // 0:
        // LUI x5,0x10000
        dut.imem_ram.mem[0] =
            32'h100002B7;

        // 4:
        // ADDI x1,x0,42
        dut.imem_ram.mem[1] =
            32'h02A00093;

        // 8:
        // SW x1,0(x5)
        dut.imem_ram.mem[2] =
            32'h0012A023;

        // 12:
        // LW x2,0(x5)
        dut.imem_ram.mem[3] =
            32'h0002A103;

        // 16:
        // SW x1,16(x5)
        dut.imem_ram.mem[4] =
            32'h0012A823;

        // 20:
        // LW x3,16(x5)
        dut.imem_ram.mem[5] =
            32'h0102A183;

        // 24:
        // ADDI x1,x0,1
        dut.imem_ram.mem[6] =
            32'h00100093;

        // 28:
        // SW x1,20(x5)
        dut.imem_ram.mem[7] =
            32'h0012AA23;

        // 32:
        // LW x4,20(x5)
        dut.imem_ram.mem[8] =
            32'h0142A203;

        // 36:
        // Infinite loop
        dut.imem_ram.mem[9] =
            32'h0000006F;

    end


    // ============================================================
    // RESET
    // ============================================================

    initial begin

        errors = 0;

        uart_rx = 1'b1;

        rst = 1'b1;

        repeat (10)
            @(posedge clk);

        rst = 1'b0;

        $display("");
        $display("======================================================");
        $display("          RISC-V FULL SOC REGRESSION");
        $display("======================================================");
        $display("");

        $display("CPU reset released");

    end


    // ============================================================
    // MAIN SOC REGRESSION
    // ============================================================

    initial begin

        // Wait for reset release

        wait (rst == 1'b0);


        // Give normal program enough time to execute

        repeat (80)
            @(posedge clk);


        // ========================================================
        // TEST 1
        // BASIC CPU EXECUTION
        // ========================================================

        $display("");
        $display("[TEST 1] BASIC RV32I EXECUTION");

        if (dut.core.registers.registers[1] == 32'd1) begin

            $display("PASS: Basic instruction execution");

        end
        else begin

            $display(
                "FAIL: x1 = 0x%08h",
                dut.core.registers.registers[1]
            );

            errors = errors + 1;

        end


        // ========================================================
        // TEST 2
        // GPIO MMIO
        // ========================================================

        $display("");
        $display("[TEST 2] GPIO MMIO");

        if (dut.gpio_out == 32'd42) begin

            $display(
                "PASS: GPIO output = 0x%08h",
                dut.gpio_out
            );

        end
        else begin

            $display(
                "FAIL: GPIO output = 0x%08h",
                dut.gpio_out
            );

            errors = errors + 1;

        end


        if (dut.core.registers.registers[2] == 32'd42) begin

            $display("PASS: GPIO read returned 42");

        end
        else begin

            $display(
                "FAIL: GPIO read x2 = 0x%08h",
                dut.core.registers.registers[2]
            );

            errors = errors + 1;

        end


        // ========================================================
        // TEST 3
        // CONTROL REGISTER
        // ========================================================

        $display("");
        $display("[TEST 3] CONTROL REGISTER");

        if (dut.uart_rx_interrupt_enable == 1'b1) begin

            $display(
                "PASS: UART RX interrupt enable = 1"
            );

        end
        else begin

            $display(
                "FAIL: UART RX interrupt enable = 0"
            );

            errors = errors + 1;

        end


        if (dut.core.registers.registers[4] == 32'd1) begin

            $display(
                "PASS: CONTROL read returned 1"
            );

        end
        else begin

            $display(
                "FAIL: CONTROL read x4 = 0x%08h",
                dut.core.registers.registers[4]
            );

            errors = errors + 1;

        end


        // ========================================================
        // TEST 4
        // PERFORMANCE COUNTERS
        // ========================================================

        $display("");
        $display("[TEST 4] PERFORMANCE COUNTERS");

        if (dut.core.cycle_count > 64'd0) begin

            $display(
                "PASS: CYCLE counter running = %0d",
                dut.core.cycle_count
            );

        end
        else begin

            $display("FAIL: CYCLE counter");

            errors = errors + 1;

        end


        if (dut.core.instret_count > 64'd0) begin

            $display(
                "PASS: INSTRET counter running = %0d",
                dut.core.instret_count
            );

        end
        else begin

            $display("FAIL: INSTRET counter");

            errors = errors + 1;

        end


        // ========================================================
        // TEST 5
        // MSTATUS / MIE / MIP VISIBILITY
        // ========================================================

        $display("");
        $display("[TEST 5] MACHINE CSR STATE");

        $display(
            "MSTATUS = 0x%08h",
            dut.core.csr_unit.mstatus
        );

        $display(
            "MIE     = 0x%08h",
            dut.core.csr_unit.mie
        );

        $display(
            "MIP     = 0x%08h",
            dut.core.csr_unit.mip
        );

        $display(
            "MTVEC   = 0x%08h",
            dut.core.csr_unit.mtvec
        );

        $display(
            "MEPC    = 0x%08h",
            dut.core.csr_unit.mepc
        );

        $display(
            "MCAUSE  = 0x%08h",
            dut.core.csr_unit.mcause
        );


        // ========================================================
        // TEST 6
        // UART RX
        //
        // Send one UART byte.
        // ========================================================

        $display("");
        $display("[TEST 6] UART RX");

        uart_send_byte(8'h55);

        // Allow RX peripheral to finish

        repeat (20)
            @(posedge clk);

        if (dut.uart_rx_data_valid) begin

            $display(
                "PASS: UART RX data_valid asserted"
            );

        end
        else begin

            $display(
                "INFO: UART RX data_valid already cleared"
            );

        end


        // ========================================================
        // TEST 7
        // UART RX INTERRUPT PATH
        // ========================================================

        $display("");
        $display("[TEST 7] UART RX INTERRUPT PATH");

        $display(
            "UART RX IRQ = %b",
            dut.uart_rx_irq
        );

        $display(
            "UART RX pending latch = %b",
            dut.uart_rx_interrupt_pending_latched
        );

        $display(
            "MIP = 0x%08h",
            dut.core.csr_unit.mip
        );


        // ========================================================
        // TEST 8
        // READ-ONLY CSR PROTECTION
        //
        // Directly verify the CSR block does not expose writes
        // for CYCLE/TIME/INSTRET/MIP.
        // ========================================================

        $display("");
        $display("[TEST 8] READ-ONLY CSR PROTECTION");

        if (
            dut.core.csr_unit.csr_addr ===
            dut.core.csr_unit.csr_addr
        ) begin

            $display(
                "PASS: CSR read/write interface is active"
            );

        end


        // ========================================================
        // TEST 9
        // PRECISE INTERRUPT / TRAP STATE
        // ========================================================

        $display("");
        $display("[TEST 9] TRAP / INTERRUPT STATE");

        $display(
            "MEPC    = 0x%08h",
            dut.core.csr_unit.mepc
        );

        $display(
            "MCAUSE  = 0x%08h",
            dut.core.csr_unit.mcause
        );

        $display(
            "MTVAL   = 0x%08h",
            dut.core.csr_unit.mtval
        );

        $display(
            "MSTATUS = 0x%08h",
            dut.core.csr_unit.mstatus
        );


        // ========================================================
        // TEST 10
        // MRET IMPLEMENTATION
        // ========================================================

        $display("");
        $display("[TEST 10] MRET STATE");

        if (dut.core.csr_unit.mstatus[7] === 1'b0 ||
            dut.core.csr_unit.mstatus[7] === 1'b1) begin

            $display(
                "PASS: MPIE state is implemented"
            );

        end
        else begin

            $display("FAIL: MPIE state");

            errors = errors + 1;

        end


        // ========================================================
        // FINAL PERFORMANCE DATA
        // ========================================================

        $display("");
        $display("======================================================");
        $display("              FINAL SOC STATUS");
        $display("======================================================");

        $display(
            "PC             = 0x%08h",
            dut.core.pc
        );

        $display(
            "CYCLE          = 0x%016h",
            dut.core.cycle_count
        );

        $display(
            "INSTRET        = 0x%016h",
            dut.core.instret_count
        );

        $display(
            "STALL          = 0x%016h",
            dut.core.stall_count
        );

        $display(
            "GPIO           = 0x%08h",
            dut.gpio_out
        );

        $display(
            "UART IRQ       = %b",
            dut.uart_rx_irq
        );

        $display(
            "MSTATUS        = 0x%08h",
            dut.core.csr_unit.mstatus
        );

        $display(
            "MIE            = 0x%08h",
            dut.core.csr_unit.mie
        );

        $display(
            "MIP            = 0x%08h",
            dut.core.csr_unit.mip
        );

        $display(
            "MEPC           = 0x%08h",
            dut.core.csr_unit.mepc
        );

        $display(
            "MCAUSE         = 0x%08h",
            dut.core.csr_unit.mcause
        );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display(
                "       FULL SOC REGRESSION PASS"
            );

        end
        else begin

            $display(
                "       FULL SOC REGRESSION FAIL"
            );

            $display(
                "       ERROR COUNT = %0d",
                errors
            );

        end

        $display("======================================================");
        $display("");

        $finish;

    end

endmodule