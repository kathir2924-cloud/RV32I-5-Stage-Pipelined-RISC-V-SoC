`timescale 1ns/1ps

module riscv_interrupt_priority_tb;

    reg clk;
    reg rst;
    reg uart_rx;
    reg uart_rx_irq;

    integer errors;
    integer i;

    reg interrupt_seen;
    reg [31:0] captured_cause;
    reg [31:0] captured_pc;

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
        forever #5 clk = ~clk;
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


    // ============================================================
    // PROGRAM
    // ============================================================

    initial begin

        errors = 0;
        interrupt_seen = 1'b0;
        captured_cause = 32'b0;
        captured_pc = 32'b0;

        rst = 1'b1;

        uart_rx = 1'b1;

        // UART interrupt is active from the beginning.
        uart_rx_irq = 1'b1;


        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'h00000013;


        // --------------------------------------------------------
        // MTVEC = 0x80
        // --------------------------------------------------------

        memory[0] = enc_addi(
            5,
            0,
            12'h080
        );

        memory[1] = enc_csrrw(
            0,
            5,
            12'h305
        );


        // --------------------------------------------------------
        // MIE = MTIE | MEIE
        //
        // 0x080 | 0x800 = 0x880
        // --------------------------------------------------------

        memory[2] = enc_addi(
            6,
            0,
            12'h880
        );

        memory[3] = enc_csrrw(
            0,
            6,
            12'h304
        );


        // --------------------------------------------------------
        // MSTATUS.MIE = 1
        // --------------------------------------------------------

        memory[4] = enc_addi(
            7,
            0,
            12'h008
        );

        memory[5] = enc_csrrs(
            0,
            7,
            12'h300
        );


        // --------------------------------------------------------
        // One normal instruction
        // --------------------------------------------------------

        memory[6] = enc_addi(
            10,
            0,
            12'h011
        );


        // --------------------------------------------------------
        // Interrupt handler @ 0x80
        // --------------------------------------------------------

        // Read MCAUSE into x13
        memory[32] = enc_csrrs(
            13,
            0,
            12'h342
        );

        // Store cause at memory[100]
        memory[33] = enc_addi(
            14,
            0,
            12'h190
        );

        memory[34] = {
            7'b0000000,
            5'd13,
            5'd14,
            3'b010,
            5'b00000,
            7'b0100011
        };

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
        $display("       TIMER + UART INTERRUPT PRIORITY TEST");
        $display("======================================================");
        $display("");

    end


    // ============================================================
    // INTERRUPT MONITOR
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            if (dut.interrupt_taken && !interrupt_seen) begin

                interrupt_seen = 1'b1;

                captured_cause = dut.interrupt_cause;
                captured_pc = dut.pc;

                $display("");
                $display(
                    "INTERRUPT TAKEN: PC=0x%08h",
                    captured_pc
                );

                $display(
                    "Interrupt Cause = 0x%08h",
                    captured_cause
                );

                $display(
                    "UART Pending = %b",
                    dut.uart_rx_interrupt_pending
                );

                $display(
                    "Timer Pending = %b",
                    dut.timer_interrupt_pending
                );

            end

        end

    end


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        wait (rst == 1'b0);


        // Wait for both sources to become active.
        wait (
            dut.timer_interrupt == 1'b1 &&
            dut.uart_rx_interrupt_to_csr == 1'b1
        );


        $display("");
        $display("Both interrupt sources are active.");


        // Give CPU enough cycles to accept interrupt.
        repeat (15)
            @(posedge clk);


        $display("");
        $display("--------------- PRIORITY STATE ----------------");

        $display(
            "Timer IRQ       = %b",
            dut.timer_interrupt
        );

        $display(
            "UART IRQ        = %b",
            dut.uart_rx_interrupt_to_csr
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
            "Captured Cause  = 0x%08h",
            captured_cause
        );


        // --------------------------------------------------------
        // Both interrupt sources must exist.
        // --------------------------------------------------------

        if (dut.timer_interrupt == 1'b1)

            $display(
                "PASS: Timer interrupt active"
            );

        else begin

            $display(
                "FAIL: Timer interrupt inactive"
            );

            errors = errors + 1;

        end


        if (dut.uart_rx_interrupt_to_csr == 1'b1)

            $display(
                "PASS: UART interrupt active"
            );

        else begin

            $display(
                "FAIL: UART interrupt inactive"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // CPU must accept interrupt.
        // --------------------------------------------------------

        if (interrupt_seen)

            $display(
                "PASS: CPU accepted interrupt"
            );

        else begin

            $display(
                "FAIL: CPU did not accept interrupt"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // UART must win.
        // --------------------------------------------------------

        if (captured_cause == 32'h8000000B)

            $display(
                "PASS: UART external interrupt has priority"
            );

        else begin

            $display(
                "FAIL: Wrong interrupt selected"
            );

            $display(
                "Expected = 0x8000000B"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MCAUSE stored by handler.
        // --------------------------------------------------------

        $display(
            "Stored MCAUSE = 0x%08h",
            memory[100]
        );


        if (memory[100] == 32'h8000000B)

            $display(
                "PASS: Handler received UART cause"
            );

        else begin

            $display(
                "FAIL: Handler received incorrect cause"
            );

            errors = errors + 1;

        end


        $display("");
        $display("======================================================");

        if (errors == 0)

            $display(
                "       TIMER + UART PRIORITY TEST PASS"
            );

        else begin

            $display(
                "       TIMER + UART PRIORITY TEST FAIL"
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