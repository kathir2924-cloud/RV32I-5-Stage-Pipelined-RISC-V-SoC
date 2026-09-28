`timescale 1ns/1ps

module riscv_timer_masking_tb;

    reg clk;
    reg rst;
    reg uart_rx;
    reg uart_rx_irq;

    integer errors;
    integer i;

    reg interrupt_seen;

    wire [31:0] imem_addr;
    reg  [31:0] imem_rdata;

    wire        dmem_read;
    wire        dmem_write;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    reg  [31:0] dmem_rdata;

    wire        mmio_read;
    wire        mmio_write;
    wire [31:0] mmio_addr;
    wire [31:0] mmio_wdata;
    reg  [31:0] mmio_rdata;

    reg [31:0] memory [0:1023];


    // ============================================================
    // DUT
    // ============================================================

    riscv_core #(
        .SOC_MODE(1'b1)
    ) dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx),

        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),

        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata),

        .mmio_read(mmio_read),
        .mmio_write(mmio_write),
        .mmio_addr(mmio_addr),
        .mmio_wdata(mmio_wdata),
        .mmio_rdata(mmio_rdata),

        .uart_rx_irq(uart_rx_irq)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;

        forever
            #5 clk = ~clk;
    end


    // ============================================================
    // INSTRUCTION MEMORY
    // ============================================================

    always @(*) begin

        if (imem_addr[31:2] < 1024)
            imem_rdata = memory[imem_addr[31:2]];
        else
            imem_rdata = 32'h00000013;

    end


    // ============================================================
    // DATA MEMORY
    // ============================================================

    always @(*) begin

        dmem_rdata = 32'b0;

        if (dmem_read) begin

            if (dmem_addr[31:2] < 1024)
                dmem_rdata = memory[dmem_addr[31:2]];

        end

    end


    always @(posedge clk) begin

        if (dmem_write) begin

            if (dmem_addr[31:2] < 1024)
                memory[dmem_addr[31:2]] <= dmem_wdata;

        end

    end


    // ============================================================
    // MMIO
    // ============================================================

    always @(*) begin
        mmio_rdata = 32'b0;
    end


    // ============================================================
    // ENCODERS
    // ============================================================

    function [31:0] enc_addi;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;

        begin

            enc_addi = {
                imm,
                rs1,
                3'b000,
                rd,
                7'b0010011
            };

        end

    endfunction


    function [31:0] enc_csrrw;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] csr;

        begin

            enc_csrrw = {
                csr,
                rs1,
                3'b001,
                rd,
                7'b1110011
            };

        end

    endfunction


    function [31:0] enc_csrrs;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] csr;

        begin

            enc_csrrs = {
                csr,
                rs1,
                3'b010,
                rd,
                7'b1110011
            };

        end

    endfunction


    function [31:0] enc_sw;

        input [4:0] rs2;
        input [4:0] rs1;
        input [11:0] imm;

        begin

            enc_sw = {
                imm[11:5],
                rs2,
                rs1,
                3'b010,
                imm[4:0],
                7'b0100011
            };

        end

    endfunction


    // ============================================================
    // PROGRAM
    // ============================================================

    initial begin

        errors = 0;
        interrupt_seen = 1'b0;

        rst = 1'b1;

        uart_rx = 1'b1;
        uart_rx_irq = 1'b0;


        // --------------------------------------------------------
        // Initialize memory with NOPs
        // --------------------------------------------------------

        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'h00000013;


        // ========================================================
        // MAIN PROGRAM
        // ========================================================

        // --------------------------------------------------------
        // 0x00:
        // x5 = 0x80
        // --------------------------------------------------------

        memory[0] = enc_addi(
            5,
            0,
            12'h080
        );


        // --------------------------------------------------------
        // 0x04:
        // MTVEC = x5
        // --------------------------------------------------------

        memory[1] = enc_csrrw(
            0,
            5,
            12'h305
        );


        // --------------------------------------------------------
        // 0x08:
        // x6 = 0x80
        // --------------------------------------------------------

        memory[2] = enc_addi(
            6,
            0,
            12'h080
        );


        // --------------------------------------------------------
        // 0x0C:
        // MIE.MTIE = 1
        // --------------------------------------------------------

        memory[3] = enc_csrrw(
            0,
            6,
            12'h304
        );


        // --------------------------------------------------------
        // 0x10 - 0x2C:
        // NOPs
        //
        // MSTATUS.MIE remains 0.
        //
        // Timer is allowed to expire here.
        //
        // The timer interrupt must NOT be accepted because:
        //
        // MSTATUS.MIE = 0
        // --------------------------------------------------------

        memory[4]  = 32'h00000013;
        memory[5]  = 32'h00000013;
        memory[6]  = 32'h00000013;
        memory[7]  = 32'h00000013;
        memory[8]  = 32'h00000013;
        memory[9]  = 32'h00000013;
        memory[10] = 32'h00000013;
        memory[11] = 32'h00000013;


        // --------------------------------------------------------
        // 0x30:
        // x7 = 8
        //
        // Bit 3 = MSTATUS.MIE
        // --------------------------------------------------------

        memory[12] = enc_addi(
            7,
            0,
            12'h008
        );


        // --------------------------------------------------------
        // 0x34:
        // MSTATUS.MIE = 1
        //
        // CSRRS x0, x7, MSTATUS
        // --------------------------------------------------------

        memory[13] = enc_csrrs(
            0,
            7,
            12'h300
        );


        // --------------------------------------------------------
        // Normal program
        // --------------------------------------------------------

        memory[14] = enc_addi(
            10,
            0,
            12'h011
        );

        memory[15] = enc_addi(
            11,
            0,
            12'h022
        );

        memory[16] = enc_addi(
            12,
            0,
            12'h033
        );


        // ========================================================
        // TIMER INTERRUPT HANDLER
        // ========================================================
        //
        // MTVEC = 0x80
        //
        // 0x80:
        //     CSRR x13, MCAUSE
        //
        // 0x84:
        //     x14 = 0x190
        //
        // 0x88:
        //     SW x13, 0(x14)
        //
        // 0x8C:
        //     Infinite loop
        //
        // IMPORTANT:
        // We intentionally DO NOT execute MRET here.
        //
        // This prevents the CPU from returning to the normal
        // program and eventually executing another instruction
        // that could overwrite MCAUSE.
        // ========================================================

        memory[32] = enc_csrrs(
            13,
            0,
            12'h342
        );


        memory[33] = enc_addi(
            14,
            0,
            12'h190
        );


        memory[34] = enc_sw(
            13,
            14,
            12'h000
        );


        // --------------------------------------------------------
        // Infinite loop
        //
        // JAL x0, 0
        //
        // This encoding is:
        // 0x0000006F
        //
        // PC remains at 0x8C.
        // --------------------------------------------------------

        memory[35] = 32'h0000006F;

    end


    // ============================================================
    // RESET
    // ============================================================

    initial begin

        repeat (8)
            @(posedge clk);

        rst = 1'b0;

        $display("");
        $display("======================================================");
        $display("          TIMER INTERRUPT MASKING TEST");
        $display("======================================================");
        $display("");

    end


    // ============================================================
    // INTERRUPT MONITOR
    // ============================================================

    always @(posedge clk) begin

        if (!rst && dut.interrupt_taken) begin

            if (!interrupt_seen) begin

                interrupt_seen = 1'b1;

                $display("");
                $display(
                    "INTERRUPT TAKEN: PC=0x%08h CAUSE=0x%08h",
                    dut.pc,
                    dut.interrupt_cause
                );

            end

        end

    end


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        wait (rst == 1'b0);


        // ========================================================
        // MASKED STATE
        // ========================================================
        //
        // Wait until PC = 0x20.
        //
        // At this point:
        //
        // MTVEC configured
        // MTIE enabled
        // MSTATUS.MIE still 0
        //
        // Timer may or may not have expired yet.
        // We verify that CPU has not accepted the interrupt.
        // ========================================================

        wait (dut.pc == 32'h00000020);


        $display("");
        $display("--------------- MASKED STATE ----------------");


        $display(
            "PC              = 0x%08h",
            dut.pc
        );


        $display(
            "Timer IRQ       = %b",
            dut.timer_interrupt
        );


        $display(
            "MSTATUS         = 0x%08h",
            dut.csr_unit.mstatus
        );


        $display(
            "MIE             = 0x%08h",
            dut.csr_unit.mie
        );


        $display(
            "MIP             = 0x%08h",
            dut.csr_unit.mip
        );


        $display(
            "Timer Pending   = %b",
            dut.timer_interrupt_pending
        );


        $display(
            "Interrupt Taken = %b",
            dut.interrupt_taken
        );


        // --------------------------------------------------------
        // Check MSTATUS.MIE = 0
        // --------------------------------------------------------

        if (dut.csr_unit.mstatus[3] == 1'b0)

            $display(
                "PASS: MSTATUS.MIE = 0 while timer active"
            );

        else begin

            $display(
                "FAIL: MSTATUS.MIE unexpectedly enabled"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // CPU must not accept interrupt
        // --------------------------------------------------------

        if (!dut.interrupt_taken)

            $display(
                "PASS: Timer interrupt masked"
            );

        else begin

            $display(
                "FAIL: CPU accepted masked timer interrupt"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // Handler must not have been entered
        // --------------------------------------------------------

        if (!interrupt_seen)

            $display(
                "PASS: Handler not entered while masked"
            );

        else begin

            $display(
                "FAIL: Handler entered while masked"
            );

            errors = errors + 1;

        end


        // ========================================================
        // UNMASK
        // ========================================================
        //
        // Continue until the CSRRS MSTATUS instruction.
        //
        // 0x34 = CSRRS x0,x7,MSTATUS
        // ========================================================

        wait (dut.pc == 32'h00000034);


        // --------------------------------------------------------
        // Give CSRRS enough cycles to execute.
        // --------------------------------------------------------

        repeat (8)
            @(posedge clk);


        $display("");
        $display("--------------- ENABLED STATE ----------------");


        $display(
            "PC              = 0x%08h",
            dut.pc
        );


        $display(
            "MSTATUS         = 0x%08h",
            dut.csr_unit.mstatus
        );


        $display(
            "MIE             = 0x%08h",
            dut.csr_unit.mie
        );


        $display(
            "MIP             = 0x%08h",
            dut.csr_unit.mip
        );


        $display(
            "Timer Pending   = %b",
            dut.timer_interrupt_pending
        );


        $display(
            "Interrupt Seen  = %b",
            interrupt_seen
        );


        // --------------------------------------------------------
        // Timer interrupt must eventually be accepted.
        // --------------------------------------------------------

        if (interrupt_seen)

            $display(
                "PASS: Timer interrupt entered after unmasking"
            );

        else begin

            $display(
                "FAIL: Timer interrupt did not enter after unmasking"
            );

            errors = errors + 1;

        end


        // ========================================================
        // Wait for handler to store MCAUSE
        // ========================================================
        //
        // The handler stores MCAUSE into memory[100].
        //
        // Wait until that memory location contains the expected
        // interrupt cause.
        //
        // We use a bounded loop so the simulation cannot freeze.
        // ========================================================

        for (i = 0; i < 20; i = i + 1) begin

            @(posedge clk);

            if (memory[100] == 32'h80000007)
                i = 20;

        end


        // ========================================================
        // CHECK MCAUSE
        // ========================================================

        $display(
            "Stored MCAUSE = 0x%08h",
            memory[100]
        );


        if (memory[100] == 32'h80000007)

            $display(
                "PASS: Timer interrupt cause correct"
            );

        else begin

            $display(
                "FAIL: Timer interrupt cause incorrect"
            );

            errors = errors + 1;

        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("======================================================");


        if (errors == 0)

            $display(
                "       TIMER INTERRUPT MASKING TEST PASS"
            );

        else begin

            $display(
                "       TIMER INTERRUPT MASKING TEST FAIL"
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