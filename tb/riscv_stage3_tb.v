`timescale 1ns/1ps

module riscv_stage3_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    wire [31:0] imem_addr;
    wire [31:0] imem_rdata;

    wire        dmem_read;
    wire        dmem_write;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    wire [31:0] dmem_rdata;

    wire        mmio_read;
    wire        mmio_write;
    wire [31:0] mmio_addr;
    wire [31:0] mmio_wdata;
    wire [31:0] mmio_rdata;

    wire uart_rx_irq;

    reg [31:0] memory [0:255];

    integer i;
    integer errors;

    /*
     * =====================================================
     * CPU
     * =====================================================
     */

    riscv_core #(
        .CSR_TEST               (1'b0),
        .TRAP_TEST              (1'b0),
        .TIMER_TEST             (1'b0),
        .MMIO_TEST              (1'b0),
        .UART_TX_TEST           (1'b0),
        .UART_RX_TEST           (1'b0),
        .UART_RX_INTERRUPT_TEST (1'b0),
        .SOC_MODE               (1'b1)
    ) dut (
        .clk        (clk),
        .rst        (rst),
        .uart_rx    (uart_rx),

        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),

        .dmem_read  (dmem_read),
        .dmem_write (dmem_write),
        .dmem_addr  (dmem_addr),
        .dmem_wdata (dmem_wdata),
        .dmem_rdata (dmem_rdata),

        .mmio_read  (mmio_read),
        .mmio_write (mmio_write),
        .mmio_addr  (mmio_addr),
        .mmio_wdata (mmio_wdata),
        .mmio_rdata (mmio_rdata),

        .uart_rx_irq(uart_rx_irq)
    );


    /*
     * =====================================================
     * INSTRUCTION MEMORY
     * =====================================================
     */

    assign imem_rdata = memory[imem_addr[9:2]];


    /*
     * =====================================================
     * DATA MEMORY
     * =====================================================
     */

    assign dmem_rdata = memory[dmem_addr[9:2]];

    always @(posedge clk) begin
        if (dmem_write)
            memory[dmem_addr[9:2]] <= dmem_wdata;
    end


    /*
     * =====================================================
     * MMIO
     * =====================================================
     */

    assign mmio_rdata = 32'b0;

    assign uart_rx_irq = 1'b0;


    /*
     * =====================================================
     * CLOCK
     * =====================================================
     */

    always #5 clk = ~clk;


    /*
     * =====================================================
     * TEST
     * =====================================================
     */

    initial begin

        clk     = 1'b0;
        rst     = 1'b1;
        uart_rx = 1'b1;
        errors  = 0;


        /*
         * Clear memory
         */

        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;


        /*
         * =================================================
         * MAIN PROGRAM
         * =================================================
         *
         * 0x00  ADDI  x5,x0,0x100
         * 0x04  CSRRW x0,MTVEC,x5
         *
         * 0x08  ADDI  x6,x0,0x55
         * 0x0C  CSRRW x10,MSCRATCH,x6
         *
         * 0x10  CSRRS x11,MSCRATCH,x6
         * 0x14  CSRRC x12,MSCRATCH,x6
         *
         * 0x18  CSRRWI x13,MSCRATCH,10
         * 0x1C  CSRRSI x0,MSCRATCH,15
         * 0x20  CSRRCI x0,MSCRATCH,15
         *
         * 0x24  ADDI x6,x0,8
         * 0x28  CSRRS x0,MSTATUS,x6
         * 0x2C  CSRR x17,MSTATUS
         * 0x30  CSRR x18,MIE
         * 0x34  CSRR x19,MSCRATCH
         *
         * 0x38  ECALL
         * 0x3C  ADDI x16,x0,0x66
         * 0x40  JAL x0,0
         */


        /*
         * 0x00
         * ADDI x5,x0,0x100
         */

        memory[0] = 32'h10000293;


        /*
         * 0x04
         * CSRRW x0,MTVEC,x5
         */

        memory[1] = 32'h30529073;


        /*
         * 0x08
         * ADDI x6,x0,0x55
         */

        memory[2] = 32'h05500313;


        /*
         * 0x0C
         * CSRRW x10,MSCRATCH,x6
         */

        memory[3] = 32'h34031573;


        /*
         * 0x10
         * CSRRS x11,MSCRATCH,x6
         */

        memory[4] = 32'h340325F3;


        /*
         * 0x14
         * CSRRC x12,MSCRATCH,x6
         */

        memory[5] = 32'h34033673;


        /*
         * 0x18
         * CSRRWI x13,MSCRATCH,10
         */

        memory[6] = 32'h340516F3;


        /*
         * 0x1C
         * CSRRSI x0,MSCRATCH,15
         */

        memory[7] = 32'h3407E073;


        /*
         * 0x20
         * CSRRCI x0,MSCRATCH,15
         */

        memory[8] = 32'h3407F073;


        /*
         * 0x24
         * ADDI x6,x0,8
         */

        memory[9] = 32'h00800313;


        /*
         * 0x28
         * CSRRS x0,MSTATUS,x6
         */

        memory[10] = 32'h30032073;


        /*
         * 0x2C
         * CSRR x17,MSTATUS
         */

        memory[11] = 32'h300028F3;


        /*
         * 0x30
         * CSRR x18,MIE
         */

        memory[12] = 32'h30402973;


        /*
         * 0x34
         * CSRR x19,MSCRATCH
         */

        memory[13] = 32'h340029F3;


        /*
         * 0x38
         * ECALL
         */

        memory[14] = 32'h00000073;


        /*
         * 0x3C
         * ADDI x16,x0,0x66
         */

        memory[15] = 32'h06600813;


        /*
         * 0x40
         * Infinite loop
         */

        memory[16] = 32'h0000006F;


        /*
         * =================================================
         * ECALL HANDLER @ 0x100
         * =================================================
         *
         * 0x100 CSRR  x14,MCAUSE
         * 0x104 CSRR  x15,MEPC
         * 0x108 ADDI  x20,x15,4
         * 0x10C CSRRW x0,MEPC,x20
         * 0x110 MRET
         */


        /*
         * 0x100
         * CSRR x14,MCAUSE
         */

        memory[64] = 32'h34202773;


        /*
         * 0x104
         * CSRR x15,MEPC
         */

        memory[65] = 32'h341027F3;


        /*
         * 0x108
         * ADDI x20,x15,4
         */

        memory[66] = 32'h00478A13;


        /*
         * 0x10C
         * CSRRW x0,MEPC,x20
         */

        memory[67] = 32'h341A1073;


        /*
         * 0x110
         * MRET
         */

        memory[68] = 32'h30200073;


        /*
         * =================================================
         * RELEASE RESET
         * =================================================
         */

        #20;
        rst = 1'b0;


        /*
         * =================================================
         * RUN MAIN PROGRAM
         * =================================================
         *
         * Run enough cycles for:
         *
         * CSR operations
         * ECALL
         * handler
         * MRET
         * post-MRET instruction
         */

        repeat (100)
            @(posedge clk);

        #1;


        /*
         * =================================================
         * STAGE 3 HEADER
         * =================================================
         */

        $display("");
        $display("======================================================");
        $display("       STAGE 3 - PRIVILEGED CSR TEST");
        $display("======================================================");
        $display("");


        /*
         * =================================================
         * CSRRW
         * =================================================
         */

        $display("---------------- CSRRW ----------------");

        $display("x10 = 0x%08h",
                 dut.registers.registers[10]);

        if (dut.registers.registers[10] == 32'h00000000) begin
            $display("PASS: CSRRW returned old MSCRATCH");
        end
        else begin
            $display("FAIL: CSRRW");
            errors = errors + 1;
        end


        /*
         * =================================================
         * CSRRS
         * =================================================
         */

        $display("");
        $display("---------------- CSRRS ----------------");

        $display("x11 = 0x%08h",
                 dut.registers.registers[11]);

        if (dut.registers.registers[11] == 32'h00000055) begin
            $display("PASS: CSRRS read MSCRATCH");
        end
        else begin
            $display("FAIL: CSRRS");
            errors = errors + 1;
        end


        /*
         * =================================================
         * CSRRC
         * =================================================
         */

        $display("");
        $display("---------------- CSRRC ----------------");

        $display("x12 = 0x%08h",
                 dut.registers.registers[12]);

        if (dut.registers.registers[12] == 32'h00000055) begin
            $display("PASS: CSRRC read MSCRATCH");
        end
        else begin
            $display("FAIL: CSRRC");
            errors = errors + 1;
        end


        /*
         * =================================================
         * CSRRWI
         * =================================================
         */

        $display("");
        $display("---------------- CSRRWI ----------------");

        $display("x13 = 0x%08h",
                 dut.registers.registers[13]);

        /*
         * After CSRRC:
         *
         * MSCRATCH = 0
         *
         * Therefore CSRRWI returns 0.
         */

        if (dut.registers.registers[13] == 32'h00000000) begin
            $display("PASS: CSRRWI returned old MSCRATCH");
        end
        else begin
            $display("FAIL: CSRRWI");
            errors = errors + 1;
        end


        /*
         * =================================================
         * CSRRSI / CSRRCI
         * =================================================
         */

        $display("");
        $display("---------------- CSRRSI / CSRRCI ----------------");

        $display("MSCRATCH = 0x%08h",
                 dut.csr_unit.mscratch);

        if (dut.csr_unit.mscratch == 32'h00000000) begin
            $display("PASS: CSRRSI/CSRRCI final CSR state");
        end
        else begin
            $display("FAIL: CSRRSI/CSRRCI");
            errors = errors + 1;
        end


        /*
         * =================================================
         * MSTATUS
         * =================================================
         */

        $display("");
        $display("---------------- MSTATUS ----------------");

        $display("MSTATUS = 0x%08h",
                 dut.csr_unit.mstatus);

        if (dut.csr_unit.mstatus[3] == 1'b1) begin
            $display("PASS: MSTATUS.MIE enabled");
        end
        else begin
            $display("FAIL: MSTATUS.MIE");
            errors = errors + 1;
        end


        /*
         * =================================================
         * MSTATUS READ
         * =================================================
         */

        $display("");
        $display("---------------- MSTATUS READ ----------------");

        $display("x17 = 0x%08h",
                 dut.registers.registers[17]);

        if (dut.registers.registers[17][3] == 1'b1) begin
            $display("PASS: MSTATUS CSR read");
        end
        else begin
            $display("FAIL: MSTATUS CSR read");
            errors = errors + 1;
        end


        /*
         * =================================================
         * MIE
         * =================================================
         */

        $display("");
        $display("---------------- MIE ----------------");

        $display("MIE  = 0x%08h",
                 dut.csr_unit.mie);

        $display("x18  = 0x%08h",
                 dut.registers.registers[18]);

        /*
         * MTIE must remain disabled.
         */

        if (dut.csr_unit.mie[7] == 1'b0) begin
            $display("PASS: MIE.MTIE remains disabled");
        end
        else begin
            $display("FAIL: MIE.MTIE unexpectedly enabled");
            errors = errors + 1;
        end


        /*
         * =================================================
         * ECALL
         * =================================================
         */

        $display("");
        $display("---------------- ECALL ----------------");

        $display("MCAUSE = 0x%08h",
                 dut.csr_unit.mcause);

        $display("MEPC   = 0x%08h",
                 dut.csr_unit.mepc);

        $display("MTVEC  = 0x%08h",
                 dut.csr_unit.mtvec);


        /*
         * ECALL cause = 11
         */

        if (dut.csr_unit.mcause == 32'h0000000B) begin
            $display("PASS: ECALL MCAUSE = 11");
        end
        else begin
            $display("FAIL: ECALL MCAUSE");
            errors = errors + 1;
        end


        /*
         * ECALL PC = 0x38
         */

        /*
         * After MRET the CSR MEPC has been changed to 0x3C.
         *
         * Therefore the final MEPC is expected to be 0x3C.
         *
         * We verify the handler's saved value using x15.
         */

        if (dut.registers.registers[15] == 32'h00000038) begin
            $display("PASS: ECALL handler captured MEPC");
        end
        else begin
            $display("FAIL: ECALL handler MEPC");
            errors = errors + 1;
        end


        /*
         * =================================================
         * ECALL HANDLER MCAUSE
         * =================================================
         */

        if (dut.registers.registers[14] == 32'h0000000B) begin
            $display("PASS: ECALL handler captured MCAUSE");
        end
        else begin
            $display("FAIL: ECALL handler MCAUSE");
            errors = errors + 1;
        end


        /*
         * =================================================
         * MEPC UPDATE
         * =================================================
         */

        if (dut.registers.registers[20] == 32'h0000003C) begin
            $display("PASS: ECALL handler advanced MEPC");
        end
        else begin
            $display("FAIL: ECALL handler MEPC update");
            errors = errors + 1;
        end


        /*
         * =================================================
         * POST-MRET
         * =================================================
         */

        $display("");
        $display("---------------- POST-MRET ----------------");

        $display("x16 = 0x%08h",
                 dut.registers.registers[16]);

        if (dut.registers.registers[16] == 32'h00000066) begin
            $display("PASS: Program resumed after ECALL/MRET");
        end
        else begin
            $display("FAIL: Program did not resume after MRET");
            errors = errors + 1;
        end


        /*
         * =================================================
         * FINAL RESULT
         * =================================================
         */

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display("        STAGE 3 PRIVILEGED CSR TEST PASS");

        end
        else begin

            $display("        STAGE 3 PRIVILEGED CSR TEST FAIL");
            $display("        ERROR COUNT = %0d", errors);

        end

        $display("======================================================");

        $finish;

    end

endmodule