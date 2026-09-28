`timescale 1ns/1ps

module riscv_uart_irq_mret_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    integer errors;
    integer i;

    // ============================================================
    // CPU INTERFACE
    // ============================================================

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

    reg  uart_rx_irq;


    // ============================================================
    // TEST MEMORY
    // ============================================================

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

        case (mmio_addr)

            32'h10000000:
                mmio_rdata = 32'b0;

            32'h10000008:
                mmio_rdata = 32'h00000055;

            32'h10000010:
                mmio_rdata = 32'b0;

            32'h10000014:
                mmio_rdata = 32'h00000001;

            default:
                mmio_rdata = 32'b0;

        endcase

    end


    // ============================================================
    // ENCODERS
    // ============================================================

    function [31:0] enc_lui;

        input [4:0] rd;
        input [19:0] imm;

        begin
            enc_lui = {imm, rd, 7'b0110111};
        end

    endfunction


    function [31:0] enc_addi;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;

        begin
            enc_addi =
                {imm, rs1, 3'b000, rd, 7'b0010011};
        end

    endfunction


    function [31:0] enc_sw;

        input [4:0] rs2;
        input [4:0] rs1;
        input [11:0] imm;

        begin
            enc_sw =
                {
                    imm[11:5],
                    rs2,
                    rs1,
                    3'b010,
                    imm[4:0],
                    7'b0100011
                };
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


    function [31:0] enc_mret;

        begin
            enc_mret = 32'h30200073;
        end

    endfunction


    // ============================================================
    // BEQ
    // ============================================================

    function [31:0] enc_beq;

        input [4:0] rs1;
        input [4:0] rs2;
        input integer offset;

        reg [12:0] imm;

        begin

            imm = offset;

            enc_beq =
                {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b000,
                    imm[4:1],
                    imm[11],
                    1'b0,
                    7'b1100011
                };

        end

    endfunction


    // ============================================================
    // PROGRAM
    // ============================================================

    initial begin

        errors = 0;
        rst = 1'b1;
        uart_rx = 1'b1;
        uart_rx_irq = 1'b0;

        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'h00000013;


        // ========================================================
        // MAIN PROGRAM
        // ========================================================

        // x5 = 0x80
        memory[0] =
            enc_addi(5, 0, 12'h080);

        // MTVEC = x5
        memory[1] =
            enc_csrrw(0, 5, 12'h305);


        // x6 = 0x800
        //
        // MIE.MEIE

        memory[2] =
            enc_addi(6, 0, 12'h800);

        memory[3] =
            enc_csrrw(0, 6, 12'h304);


        // x7 = 8
        //
        // MSTATUS.MIE

        memory[4] =
            enc_addi(7, 0, 12'h008);

        memory[5] =
            enc_csrrs(0, 7, 12'h300);


        // Normal program marker 1

        memory[6] =
            enc_addi(10, 0, 12'h011);


        // Normal program marker 2

        memory[7] =
            enc_addi(11, 0, 12'h022);


        // Normal program marker 3

        memory[8] =
            enc_addi(12, 0, 12'h033);


        // Infinite loop

        memory[9] =
            enc_beq(0, 0, 0);


        // ========================================================
        // INTERRUPT HANDLER @ 0x80
        // ========================================================

        // x13 = MCAUSE

        memory[32] =
            enc_csrrs(13, 0, 12'h342);


        // x14 = 400
        //
        // Store area:
        // memory[100] = MCAUSE
        // memory[101] = MEPC

        memory[33] =
            enc_addi(14, 0, 12'h190);


        // Store MCAUSE

        memory[34] =
            enc_sw(13, 14, 12'h000);


        // x15 = MEPC

        memory[35] =
            enc_csrrs(15, 0, 12'h341);


        // Store MEPC

        memory[36] =
            enc_sw(15, 14, 12'h004);


        // MRET

        memory[37] =
            enc_mret();

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
        $display("       UART IRQ -> HANDLER -> MRET TEST");
        $display("======================================================");
        $display("");

    end


    // ============================================================
    // GENERATE EXTERNAL UART INTERRUPT
    // ============================================================

    initial begin

        wait (rst == 1'b0);

        // Allow setup instructions to execute:
        //
        // MTVEC
        // MIE
        // MSTATUS

        repeat (25)
            @(posedge clk);


        $display("");
        $display("[TEST] Asserting UART external interrupt");

        uart_rx_irq = 1'b1;


        // Keep IRQ asserted long enough for CPU to enter handler.

        repeat (8)
            @(posedge clk);


        uart_rx_irq = 1'b0;

        $display("[TEST] UART external interrupt released");

    end


    // ============================================================
    // INTERRUPT MONITOR
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            if (dut.interrupt_taken) begin

                $display(
                    "INTERRUPT TAKEN: PC=0x%08h CAUSE=0x%08h",
                    dut.pc,
                    dut.interrupt_cause
                );

            end


            if (dut.mret_taken) begin

                $display(
                    "MRET TAKEN: MEPC=0x%08h",
                    dut.mepc_value
                );

            end

        end

    end


    // ============================================================
    // FINAL CHECKS
    // ============================================================

    initial begin

        wait (rst == 1'b0);

        // Give enough time for:
        //
        // interrupt
        // handler
        // MRET
        // resume

        repeat (100)
            @(posedge clk);


        $display("");
        $display("======================================================");
        $display("                 TEST RESULTS");
        $display("======================================================");


        // --------------------------------------------------------
        // MCAUSE
        // --------------------------------------------------------

        $display(
            "Stored MCAUSE = 0x%08h",
            memory[100]
        );

        if (memory[100] == 32'h8000000B) begin

            $display(
                "PASS: MCAUSE = UART external interrupt"
            );

        end
        else begin

            $display(
                "FAIL: MCAUSE expected 0x8000000B"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MEPC
        // --------------------------------------------------------

        $display(
            "Stored MEPC   = 0x%08h",
            memory[101]
        );

        if (memory[101] != 32'h00000000) begin

            $display(
                "PASS: MEPC captured"
            );

        end
        else begin

            $display(
                "FAIL: MEPC not captured"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MTVEC
        // --------------------------------------------------------

        $display(
            "MTVEC         = 0x%08h",
            dut.csr_unit.mtvec
        );

        if (dut.csr_unit.mtvec == 32'h00000080) begin

            $display(
                "PASS: MTVEC configured correctly"
            );

        end
        else begin

            $display(
                "FAIL: MTVEC incorrect"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MIE
        // --------------------------------------------------------

        $display(
            "MIE           = 0x%08h",
            dut.csr_unit.mie
        );

        if (dut.csr_unit.mie[11] == 1'b1) begin

            $display(
                "PASS: MIE.MEIE enabled"
            );

        end
        else begin

            $display(
                "FAIL: MIE.MEIE not enabled"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MSTATUS
        // --------------------------------------------------------

        $display(
            "MSTATUS       = 0x%08h",
            dut.csr_unit.mstatus
        );


        // --------------------------------------------------------
        // NORMAL PROGRAM RESUMPTION
        // --------------------------------------------------------

        $display(
            "x10           = 0x%08h",
            dut.registers.registers[10]
        );

        $display(
            "x11           = 0x%08h",
            dut.registers.registers[11]
        );

        $display(
            "x12           = 0x%08h",
            dut.registers.registers[12]
        );


        if (
            dut.registers.registers[10] == 32'h00000011 &&
            dut.registers.registers[11] == 32'h00000022 &&
            dut.registers.registers[12] == 32'h00000033
        ) begin

            $display(
                "PASS: Normal program executed"
            );

        end
        else begin

            $display(
                "FAIL: Normal program did not execute correctly"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // FINAL
        // --------------------------------------------------------

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display(
                "      UART IRQ HANDLER + MRET TEST PASS"
            );

        end
        else begin

            $display(
                "      UART IRQ HANDLER + MRET TEST FAIL"
            );

            $display(
                "      ERROR COUNT = %0d",
                errors
            );

        end

        $display("======================================================");
        $display("");

        $finish;

    end

endmodule