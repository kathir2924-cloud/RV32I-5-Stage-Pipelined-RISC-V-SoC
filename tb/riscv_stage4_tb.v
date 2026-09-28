`timescale 1ns/1ps

module riscv_stage4_tb;

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
     * MAIN TEST
     * =====================================================
     */

    initial begin

        clk    = 1'b0;
        rst    = 1'b1;
        uart_rx = 1'b1;
        errors = 0;


        /*
         * Clear instruction/data memory.
         */

        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;


        /*
         * =================================================
         * PROGRAM
         * =================================================
         *
         * x5  = CYCLE
         * x6  = CYCLE second read
         *
         * x7  = CYCLEH
         * x8  = TIME
         * x9  = TIMEH
         *
         * x10 = INSTRET
         * x11 = INSTRETH
         * x12 = INSTRET second read
         *
         * x13 = 0x11
         * x14 = 0x22
         * x15 = x13 + x14
         */


        /*
         * 0:
         * CSRR x5,CYCLE
         */

        memory[0] = 32'hC00022F3;


        /*
         * 4:
         * CSRR x7,CYCLEH
         */

        memory[1] = 32'hC80023F3;


        /*
         * 8:
         * CSRR x8,TIME
         */

        memory[2] = 32'hC0102473;


        /*
         * 12:
         * CSRR x9,TIMEH
         */

        memory[3] = 32'hC81024F3;


        /*
         * 16:
         * CSRR x10,INSTRET
         */

        memory[4] = 32'hC0202573;


        /*
         * 20:
         * CSRR x11,INSTRETH
         */

        memory[5] = 32'hC82025F3;


        /*
         * 24:
         * ADDI x13,x0,17
         */

        memory[6] = 32'h01100693;


        /*
         * 28:
         * ADDI x14,x0,34
         */

        memory[7] = 32'h02200713;


        /*
         * 32:
         * ADD x15,x13,x14
         */

        memory[8] = 32'h00E687B3;


        /*
         * 36:
         * CSRR x12,INSTRET
         */

        memory[9] = 32'hC0202673;


        /*
         * 40:
         * CSRR x6,CYCLE
         */

        memory[10] = 32'hC0002373;


        /*
         * 44:
         * Infinite loop
         */

        memory[11] = 32'h0000006F;


        /*
         * =================================================
         * RELEASE RESET
         * =================================================
         */

        #20;
        rst = 1'b0;


        /*
         * =================================================
         * RUN
         * =================================================
         */

        repeat (80)
            @(posedge clk);

        #1;


        /*
         * =================================================
         * HEADER
         * =================================================
         */

        $display("");
        $display("======================================================");
        $display("     STAGE 4 - 64-BIT PERFORMANCE COUNTER TEST");
        $display("======================================================");
        $display("");


        /*
         * =================================================
         * INTERNAL COUNTER SNAPSHOT
         * =================================================
         */

        $display("---------------- INTERNAL COUNTERS ----------------");

        $display("Current CYCLE   = 0x%016h",
                 dut.cycle_count);

        $display("Current INSTRET = 0x%016h",
                 dut.instret_count);

        $display("");


        /*
         * =================================================
         * CYCLE
         * =================================================
         */

        $display("---------------- CYCLE ----------------");

        $display("CYCLE #1 = 0x%08h",
                 dut.registers.registers[5]);

        $display("CYCLE #2 = 0x%08h",
                 dut.registers.registers[6]);


        if (dut.registers.registers[6] >
            dut.registers.registers[5]) begin

            $display("PASS: CYCLE counter increases");

        end
        else begin

            $display("FAIL: CYCLE counter did not increase");
            errors = errors + 1;

        end


        /*
         * =================================================
         * CYCLEH
         * =================================================
         *
         * Because the high word is zero for this short test,
         * verify that it is zero and that it is a valid
         * 32-bit upper-half read.
         */

        $display("");
        $display("---------------- CYCLEH ----------------");

        $display("CYCLEH = 0x%08h",
                 dut.registers.registers[7]);

        if (dut.registers.registers[7] == 32'h00000000) begin

            $display("PASS: CYCLEH upper word is zero");

        end
        else begin

            $display("FAIL: Unexpected CYCLEH value");
            errors = errors + 1;

        end


        /*
         * =================================================
         * TIME
         * =================================================
         *
         * TIME is currently implemented using cycle_count.
         *
         * We therefore verify that TIME is a valid counter
         * snapshot and that TIMEH is zero for this run.
         *
         * We do NOT compare TIME against the final counter,
         * because the counter continues running after the
         * CSR instruction has executed.
         */

        $display("");
        $display("---------------- TIME ----------------");

        $display("TIME = 0x%08h",
                 dut.registers.registers[8]);

        if (dut.registers.registers[8] != 32'h00000000) begin

            $display("PASS: TIME returned a valid non-zero snapshot");

        end
        else begin

            $display("FAIL: TIME returned zero");
            errors = errors + 1;

        end


        /*
         * =================================================
         * TIMEH
         * =================================================
         */

        $display("");
        $display("---------------- TIMEH ----------------");

        $display("TIMEH = 0x%08h",
                 dut.registers.registers[9]);

        if (dut.registers.registers[9] == 32'h00000000) begin

            $display("PASS: TIMEH upper word is zero");

        end
        else begin

            $display("FAIL: Unexpected TIMEH value");
            errors = errors + 1;

        end


        /*
         * =================================================
         * INSTRET
         * =================================================
         */

        $display("");
        $display("---------------- INSTRET ----------------");

        $display("INSTRET #1 = 0x%08h",
                 dut.registers.registers[10]);

        $display("INSTRET #2 = 0x%08h",
                 dut.registers.registers[12]);


        if (dut.registers.registers[12] >
            dut.registers.registers[10]) begin

            $display("PASS: INSTRET counter increases");

        end
        else begin

            $display("FAIL: INSTRET counter did not increase");
            errors = errors + 1;

        end


        /*
         * =================================================
         * INSTRETH
         * =================================================
         */

        $display("");
        $display("---------------- INSTRETH ----------------");

        $display("INSTRETH = 0x%08h",
                 dut.registers.registers[11]);

        if (dut.registers.registers[11] == 32'h00000000) begin

            $display("PASS: INSTRETH upper word is zero");

        end
        else begin

            $display("FAIL: Unexpected INSTRETH value");
            errors = errors + 1;

        end


        /*
         * =================================================
         * 64-BIT COUNTER STRUCTURE
         * =================================================
         */

        $display("");
        $display("---------------- 64-BIT COUNTER STRUCTURE ----------------");

        /*
         * Check that upper words are actually present
         * in the 64-bit counter signals.
         */

        if (dut.cycle_count[63:32] ==
            dut.registers.registers[7]) begin

            $display("PASS: CYCLEH maps to cycle_count[63:32]");

        end
        else begin

            $display("FAIL: CYCLEH mapping");
            errors = errors + 1;

        end


        if (dut.cycle_count[63:32] ==
            dut.registers.registers[9]) begin

            $display("PASS: TIMEH maps to cycle_count[63:32]");

        end
        else begin

            $display("FAIL: TIMEH mapping");
            errors = errors + 1;

        end


        if (dut.instret_count[63:32] ==
            dut.registers.registers[11]) begin

            $display("PASS: INSTRETH maps to instret_count[63:32]");

        end
        else begin

            $display("FAIL: INSTRETH mapping");
            errors = errors + 1;

        end


        /*
         * =================================================
         * NORMAL CPU EXECUTION
         * =================================================
         */

        $display("");
        $display("---------------- NORMAL CPU ----------------");

        $display("x13 = 0x%08h",
                 dut.registers.registers[13]);

        $display("x14 = 0x%08h",
                 dut.registers.registers[14]);

        $display("x15 = 0x%08h",
                 dut.registers.registers[15]);


        if (dut.registers.registers[13] == 32'h00000011) begin

            $display("PASS: x13 normal instruction");

        end
        else begin

            $display("FAIL: x13");
            errors = errors + 1;

        end


        if (dut.registers.registers[14] == 32'h00000022) begin

            $display("PASS: x14 normal instruction");

        end
        else begin

            $display("FAIL: x14");
            errors = errors + 1;

        end


        if (dut.registers.registers[15] == 32'h00000033) begin

            $display("PASS: x15 normal instruction");

        end
        else begin

            $display("FAIL: x15");
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

            $display("       STAGE 4 PERFORMANCE COUNTER TEST PASS");

        end
        else begin

            $display("       STAGE 4 PERFORMANCE COUNTER TEST FAIL");
            $display("       ERROR COUNT = %0d", errors);

        end

        $display("======================================================");

        $finish;

    end

endmodule