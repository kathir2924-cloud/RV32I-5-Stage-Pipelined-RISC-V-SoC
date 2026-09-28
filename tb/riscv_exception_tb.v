`timescale 1ns/1ps

module riscv_exception_tb;

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

    integer errors;
    integer i;

    reg [31:0] memory [0:255];

    /*
     * Latch MRET event.
     *
     * Do NOT use:
     *
     *     wait(dut.mret_taken);
     *
     * because mret_taken is a pipeline combinational pulse.
     */
    reg mret_seen;

    always @(posedge clk) begin
        if (rst)
            mret_seen <= 1'b0;
        else if (dut.mret_taken)
            mret_seen <= 1'b1;
    end


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
     * TEST PROGRAM
     * =====================================================
     */

    initial begin

        clk      = 1'b0;
        rst      = 1'b1;
        uart_rx  = 1'b1;
        errors   = 0;
        mret_seen = 1'b0;


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
         * 0x00  ADDI x5,x0,0x100
         * 0x04  CSRRW x0,MTVEC,x5
         * 0x08  ADDI x6,x0,8
         * 0x0C  CSRRS x0,MSTATUS,x6
         * 0x10  ILLEGAL
         * 0x14  ADDI x12,x0,0x33
         * 0x18  ADDI x16,x0,0x44
         * 0x1C  ADDI x17,x0,0x55
         * 0x20  JAL x0,0
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
         * ADDI x6,x0,8
         */
        memory[2] = 32'h00800313;


        /*
         * 0x0C
         * CSRRS x0,MSTATUS,x6
         *
         * Set MSTATUS.MIE = 1
         */
        memory[3] = 32'h30032073;


        /*
         * 0x10
         * Illegal instruction
         */
        memory[4] = 32'hFFFFFFFF;


        /*
         * 0x14
         * ADDI x12,x0,0x33
         */
        memory[5] = 32'h03300613;


        /*
         * 0x18
         * ADDI x16,x0,0x44
         */
        memory[6] = 32'h04400813;


        /*
         * 0x1C
         * ADDI x17,x0,0x55
         */
        memory[7] = 32'h05500893;


        /*
         * 0x20
         * Infinite loop
         */
        memory[8] = 32'h0000006F;


        /*
         * =================================================
         * EXCEPTION HANDLER
         * =================================================
         *
         * 0x100 CSRR  x20,MCAUSE
         * 0x104 CSRR  x21,MTVAL
         * 0x108 CSRR  x22,MEPC
         * 0x10C ADDI  x23,x22,4
         * 0x110 CSRRW x0,MEPC,x23
         * 0x114 MRET
         */


        /*
         * 0x100
         * CSRR x20,MCAUSE
         */
        memory[64] = 32'h34202A73;


        /*
         * 0x104
         * CSRR x21,MTVAL
         */
        memory[65] = 32'h34302AF3;


        /*
         * 0x108
         * CSRR x22,MEPC
         */
        memory[66] = 32'h34102B73;


        /*
         * 0x10C
         * ADDI x23,x22,4
         */
        memory[67] = 32'h004B0B93;


        /*
         * 0x110
         * CSRRW x0,MEPC,x23
         */
        memory[68] = 32'h341B9073;


        /*
         * 0x114
         * MRET
         */
        memory[69] = 32'h30200073;


        /*
         * =================================================
         * RELEASE RESET
         * =================================================
         */

        #20;
        rst = 1'b0;


        /*
         * =================================================
         * WAIT FOR EXCEPTION
         * =================================================
         */

        wait (dut.csr_unit.mcause == 32'h00000002);

        #1;


        /*
         * =================================================
         * EXCEPTION RESULTS
         * =================================================
         */

        $display("");
        $display("======================================================");
        $display("       STAGE 2 - EXCEPTION & TRAP TEST");
        $display("======================================================");
        $display("");

        $display("--------------- ILLEGAL INSTRUCTION ----------------");

        $display("MCAUSE = 0x%08h",
                 dut.csr_unit.mcause);

        $display("MEPC   = 0x%08h",
                 dut.csr_unit.mepc);

        $display("MTVAL  = 0x%08h",
                 dut.csr_unit.mtval);

        $display("MTVEC  = 0x%08h",
                 dut.csr_unit.mtvec);


        /*
         * MCAUSE
         */

        if (dut.csr_unit.mcause == 32'h00000002) begin
            $display("PASS: Illegal instruction MCAUSE = 2");
        end
        else begin
            $display("FAIL: Illegal instruction MCAUSE");
            errors = errors + 1;
        end


        /*
         * MEPC
         */

        if (dut.csr_unit.mepc == 32'h00000010) begin
            $display("PASS: MEPC captured illegal instruction PC");
        end
        else begin
            $display("FAIL: MEPC incorrect");
            errors = errors + 1;
        end


        /*
         * MTVAL
         */

        if (dut.csr_unit.mtval == 32'hFFFFFFFF) begin
            $display("PASS: MTVAL captured illegal instruction");
        end
        else begin
            $display("FAIL: MTVAL incorrect");
            errors = errors + 1;
        end


        /*
         * MTVEC
         */

        if (dut.csr_unit.mtvec == 32'h00000100) begin
            $display("PASS: MTVEC configured correctly");
        end
        else begin
            $display("FAIL: MTVEC incorrect");
            errors = errors + 1;
        end


        /*
         * =================================================
         * MSTATUS TRAP ENTRY
         * =================================================
         */

        $display("");
        $display("--------------- MSTATUS TRAP ENTRY ----------------");

        $display("MSTATUS = 0x%08h",
                 dut.csr_unit.mstatus);


        /*
         * MIE must become 0
         */

        if (dut.csr_unit.mstatus[3] == 1'b0) begin
            $display("PASS: MSTATUS.MIE cleared during trap");
        end
        else begin
            $display("FAIL: MSTATUS.MIE was not cleared");
            errors = errors + 1;
        end


        /*
         * MPIE must become previous MIE = 1
         */

        if (dut.csr_unit.mstatus[7] == 1'b1) begin
            $display("PASS: MSTATUS.MPIE captured previous MIE");
        end
        else begin
            $display("FAIL: MSTATUS.MPIE incorrect");
            errors = errors + 1;
        end


        /*
         * =================================================
         * WAIT FOR HANDLER
         * =================================================
         */

        repeat (8)
            @(posedge clk);

        #1;


        /*
         * =================================================
         * HANDLER STATE
         * =================================================
         */

        $display("");
        $display("--------------- HANDLER STATE ----------------");

        $display("x20 = 0x%08h",
                 dut.registers.registers[20]);

        $display("x21 = 0x%08h",
                 dut.registers.registers[21]);

        $display("x22 = 0x%08h",
                 dut.registers.registers[22]);

        $display("x23 = 0x%08h",
                 dut.registers.registers[23]);


        /*
         * MCAUSE
         */

        if (dut.registers.registers[20] == 32'h00000002) begin
            $display("PASS: Handler read MCAUSE correctly");
        end
        else begin
            $display("FAIL: Handler MCAUSE");
            errors = errors + 1;
        end


        /*
         * MTVAL
         */

        if (dut.registers.registers[21] == 32'hFFFFFFFF) begin
            $display("PASS: Handler read MTVAL correctly");
        end
        else begin
            $display("FAIL: Handler MTVAL");
            errors = errors + 1;
        end


        /*
         * MEPC
         */

        if (dut.registers.registers[22] == 32'h00000010) begin
            $display("PASS: Handler read MEPC correctly");
        end
        else begin
            $display("FAIL: Handler MEPC");
            errors = errors + 1;
        end


        /*
         * MEPC + 4
         */

        if (dut.registers.registers[23] == 32'h00000014) begin
            $display("PASS: Handler advanced MEPC by 4");
        end
        else begin
            $display("FAIL: Handler did not advance MEPC");
            errors = errors + 1;
        end


        /*
         * =================================================
         * IMPORTANT
         * =================================================
         *
         * We DO NOT use:
         *
         * wait(dut.mret_taken)
         *
         * Instead, wait until the latched event occurs.
         *
         * Timeout prevents the simulation from freezing
         * forever if MRET never occurs.
         */

        $display("");
        $display("--------------- WAITING FOR MRET ----------------");

        fork

            begin
                wait (mret_seen == 1'b1);

                $display("MRET event detected");
            end

            begin
                repeat (30)
                    @(posedge clk);

                if (mret_seen == 1'b0) begin
                    $display("FAIL: MRET was not detected");
                    errors = errors + 1;
                end
            end

        join_any

        disable fork;


        /*
         * =================================================
         * MRET STATE
         * =================================================
         */

        if (mret_seen == 1'b1) begin

            /*
             * Give CSR nonblocking assignments time to update.
             */
            repeat (2)
                @(posedge clk);

            #1;

            $display("");
            $display("--------------- MRET STATE ----------------");

            $display("MSTATUS = 0x%08h",
                     dut.csr_unit.mstatus);

            $display("MEPC    = 0x%08h",
                     dut.csr_unit.mepc);


            /*
             * MIE restored
             */

            if (dut.csr_unit.mstatus[3] == 1'b1) begin
                $display("PASS: MRET restored MSTATUS.MIE");
            end
            else begin
                $display("FAIL: MRET did not restore MSTATUS.MIE");
                errors = errors + 1;
            end


            /*
             * MPIE set to 1
             */

            if (dut.csr_unit.mstatus[7] == 1'b1) begin
                $display("PASS: MRET restored MPIE state");
            end
            else begin
                $display("FAIL: MRET MPIE state incorrect");
                errors = errors + 1;
            end

        end


        /*
         * =================================================
         * NORMAL PROGRAM
         * =================================================
         */

        repeat (10)
            @(posedge clk);

        #1;

        $display("");
        $display("--------------- NORMAL PROGRAM ----------------");

        $display("x12 = 0x%08h",
                 dut.registers.registers[12]);

        $display("x16 = 0x%08h",
                 dut.registers.registers[16]);

        $display("x17 = 0x%08h",
                 dut.registers.registers[17]);


        /*
         * x12
         */

        if (dut.registers.registers[12] == 32'h00000033) begin
            $display("PASS: Program resumed after MRET");
        end
        else begin
            $display("FAIL: Program did not resume after MRET");
            errors = errors + 1;
        end


        /*
         * x16
         */

        if (dut.registers.registers[16] == 32'h00000044) begin
            $display("PASS: Post-trap instruction executed");
        end
        else begin
            $display("FAIL: x16 incorrect");
            errors = errors + 1;
        end


        /*
         * x17
         */

        if (dut.registers.registers[17] == 32'h00000055) begin
            $display("PASS: Normal program flow restored");
        end
        else begin
            $display("FAIL: x17 incorrect");
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

            $display("        STAGE 2 EXCEPTION TEST PASS");

        end
        else begin

            $display("        STAGE 2 EXCEPTION TEST FAIL");
            $display("        ERROR COUNT = %0d", errors);

        end

        $display("======================================================");

        $finish;

    end

endmodule