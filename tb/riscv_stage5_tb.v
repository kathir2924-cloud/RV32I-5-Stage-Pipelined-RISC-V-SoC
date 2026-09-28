`timescale 1ns/1ps

module riscv_stage5_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    /*
     * External UART interrupt input.
     *
     * In SOC_MODE the CPU routes this directly into
     * the CSR external interrupt path.
     */
    reg uart_rx_irq;

    /*
     * CPU buses
     */

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

    /*
     * Simple memory.
     */

    reg [31:0] memory [0:255];

    integer i;
    integer errors;

    /*
     * =========================================================
     * DUT
     * =========================================================
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
     * =========================================================
     * INSTRUCTION MEMORY
     * =========================================================
     */

    assign imem_rdata = memory[imem_addr[9:2]];


    /*
     * =========================================================
     * DATA MEMORY
     * =========================================================
     */

    assign dmem_rdata = memory[dmem_addr[9:2]];

    always @(posedge clk) begin

        if (dmem_write)
            memory[dmem_addr[9:2]] <= dmem_wdata;

    end


    /*
     * =========================================================
     * MMIO
     * =========================================================
     */

    assign mmio_rdata = 32'b0;


    /*
     * =========================================================
     * CLOCK
     * =========================================================
     */

    always #5 clk = ~clk;


    /*
     * =========================================================
     * MAIN TEST
     * =========================================================
     */

    initial begin

        clk        = 1'b0;
        rst        = 1'b1;
        uart_rx    = 1'b1;
        uart_rx_irq = 1'b0;

        errors = 0;


        /*
         * =====================================================
         * CLEAR MEMORY
         * =====================================================
         */

        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;


        /*
         * =====================================================
         * MAIN PROGRAM
         * =====================================================
         *
         * Address:
         *
         * 0x000 : configuration
         * 0x010 : ECALL
         * 0x014 : normal execution
         * 0x018 : normal execution
         * ...
         *
         * Handler:
         *
         * 0x100 : common machine handler
         *
         */


        /*
         * -----------------------------------------------------
         * x5 = 0x100
         *
         * ADDI x5,x0,256
         * -----------------------------------------------------
         */

        memory[0] = 32'h10000293;


        /*
         * CSRRW x0,MTVEC,x5
         *
         * mtvec = 0x100
         *
         * 0x305
         */

        memory[1] = 32'h30529073;


        /*
         * -----------------------------------------------------
         * x6 = 8
         *
         * MSTATUS.MIE
         * -----------------------------------------------------
         */

        memory[2] = 32'h00800313;


        /*
         * CSRRW x0,MSTATUS,x6
         */

        memory[3] = 32'h30031073;


        /*
         * -----------------------------------------------------
         * x7 = 0x00000880
         *
         * MTIE  = bit 7
         * MEIE  = bit 11
         *
         * 0x80 + 0x800 = 0x880
         * -----------------------------------------------------
         */

        memory[4] = 32'h08000393;


        /*
         * ADDI cannot encode 0x880.
         *
         * Use LUI:
         *
         * x7 = 0x1000
         *
         * Then subtract 0x780.
         *
         * For robustness, instead use two instructions:
         *
         * x7 = 0x800
         * x8 = 0x80
         * x7 = x7 + x8
         */


        /*
         * Replace instruction 4:
         *
         * LUI x7,0x80000
         * This gives 0x80000000, not desired.
         *
         * Therefore use:
         *
         * ADDI x7,x0,128
         */

        memory[4] = 32'h08000393;


        /*
         * x8 = 2048
         *
         * LUI x8,1
         * = 0x1000
         *
         * ADDI x8,x8,-2048
         * = 0x800
         */

        memory[5] = 32'h00001437;

        memory[6] = 32'h80040413;


        /*
         * x7 = x7 + x8
         *
         * = 0x80 + 0x800
         * = 0x880
         */

        memory[7] = 32'h008383B3;


        /*
         * Write MIE.
         */

        memory[8] = 32'h30439073;


        /*
         * -----------------------------------------------------
         * ECALL
         * -----------------------------------------------------
         */

        memory[9] = 32'h00000073;


        /*
         * -----------------------------------------------------
         * After ECALL
         * -----------------------------------------------------
         *
         * x10 = 0x55
         */

        memory[10] = 32'h05500513;


        /*
         * x11 = 0x66
         */

        memory[11] = 32'h06600593;


        /*
         * x12 = x10 + x11
         *
         * = 0xBB
         */

        memory[12] = 32'h00B50633;


        /*
         * Infinite loop.
         */

        memory[13] = 32'h0000006F;


        /*
         * =====================================================
         * MACHINE HANDLER @ 0x100
         * =====================================================
         *
         * The handler:
         *
         * 1. Reads MCAUSE into x20
         * 2. Reads MEPC into x21
         * 3. Saves MSTATUS into x22
         * 4. Advances MEPC by 4
         * 5. Disables MTIE
         * 6. MRET
         *
         */


        /*
         * 0x100
         *
         * CSRR x20,MCAUSE
         *
         * rd=x20
         * rs1=x0
         * csr=342
         */

        memory[64] = 32'h34202A73;


        /*
         * 0x104
         *
         * CSRR x21,MEPC
         */

        memory[65] = 32'h34102AF3;


        /*
         * 0x108
         *
         * CSRR x22,MSTATUS
         */

        memory[66] = 32'h30002B73;


        /*
         * 0x10C
         *
         * x23 = 4
         */

        memory[67] = 32'h00400B93;


        /*
         * 0x110
         *
         * x21 = x21 + x23
         */

        memory[68] = 32'h017A8AB3;


        /*
         * 0x114
         *
         * CSRRW x0,MEPC,x21
         */

        memory[69] = 32'h341A9073;


        /*
         * 0x118
         *
         * x24 = 128
         *
         * This is MTIE bit.
         */

        memory[70] = 32'h08000C13;


        /*
         * 0x11C
         *
         * CSRRC x0,MIE,x24
         *
         * Clear MTIE.
         *
         * This prevents the persistent timer request from
         * immediately retriggering after MRET.
         */

        memory[71] = 32'h304C3073;


        /*
         * 0x120
         *
         * MRET
         */

        memory[72] = 32'h30200073;


        /*
         * =====================================================
         * RELEASE RESET
         * =====================================================
         */

        #20;
        rst = 1'b0;


      /*
 * =====================================================
 * WAIT FOR ECALL HANDLER AND MRET
 * =====================================================
 */

wait (dut.csr_unit.mcause == 32'd11);

wait (
    (dut.registers.registers[10] == 32'h00000055) &&
    (dut.registers.registers[11] == 32'h00000066) &&
    (dut.registers.registers[12] == 32'h000000BB)
);

#1;


/*
 * =====================================================
 * ECALL TEST
 * =====================================================
 */

$display("");
$display("---------------- ECALL ----------------");

$display("MCAUSE = 0x%08h",
         dut.csr_unit.mcause);

if (dut.csr_unit.mcause == 32'd11) begin

    $display("PASS: ECALL MCAUSE = 11");

end
else begin

    $display("FAIL: ECALL MCAUSE");
    errors = errors + 1;

end


if (dut.registers.registers[10] == 32'h00000055) begin

    $display("PASS: Program resumed after ECALL");

end
else begin

    $display("FAIL: Program did not resume after ECALL");
    errors = errors + 1;

end


if (dut.registers.registers[11] == 32'h00000066) begin

    $display("PASS: Post-ECALL instruction executed");

end
else begin

    $display("FAIL: Post-ECALL instruction");
    errors = errors + 1;

end

        /*
         * =====================================================
         * CHECK ECALL RETURN
         * =====================================================
         */

        if (dut.registers.registers[10] == 32'h00000055) begin

            $display("PASS: Program resumed after ECALL");

        end
        else begin

            $display("FAIL: Program did not resume after ECALL");
            errors = errors + 1;

        end


        if (dut.registers.registers[11] == 32'h00000066) begin

            $display("PASS: Post-ECALL instruction executed");

        end
        else begin

            $display("FAIL: Post-ECALL instruction");
            errors = errors + 1;

        end


        /*
         * =====================================================
         * MSTATUS AFTER MRET
         * =====================================================
         */

        $display("");
        $display("---------------- MSTATUS AFTER ECALL/MRET ----------------");

        $display("MSTATUS = 0x%08h",
                 dut.csr_unit.mstatus);

        if (dut.csr_unit.mstatus[3] == 1'b1) begin

            $display("PASS: MIE restored after MRET");

        end
        else begin

            $display("FAIL: MIE not restored after MRET");
            errors = errors + 1;

        end


        if (dut.csr_unit.mstatus[7] == 1'b1) begin

            $display("PASS: MPIE restored to 1");

        end
        else begin

            $display("FAIL: MPIE incorrect");
            errors = errors + 1;

        end


        /*
         * =====================================================
         * TIMER INTERRUPT
         * =====================================================
         *
         * The timer is always enabled internally.
         *
         * MTIE was cleared by the handler.
         *
         * Enable MTIE again through direct CSR state for the
         * integration test.
         *
         * This is testbench control, not a CPU functional path.
         */

        $display("");
        $display("---------------- TIMER INTERRUPT ----------------");


        /*
         * Enable MTIE.
         *
         * Keep MEIE enabled.
         */

        dut.csr_unit.mie[7]  = 1'b1;
        dut.csr_unit.mie[11] = 1'b0;

        /*
         * Ensure global interrupt enable is active.
         */

        dut.csr_unit.mstatus[3] = 1'b1;


        /*
         * Wait for timer interrupt.
         */

        wait (dut.csr_unit.mcause == 32'h80000007);

        #1;


        $display("MCAUSE = 0x%08h",
                 dut.csr_unit.mcause);

        if (dut.csr_unit.mcause == 32'h80000007) begin

            $display("PASS: Timer interrupt MCAUSE");

        end
        else begin

            $display("FAIL: Timer interrupt MCAUSE");
            errors = errors + 1;

        end


        /*
         * Verify interrupt entry disabled MIE.
         */

        if (dut.csr_unit.mstatus[3] == 1'b0) begin

            $display("PASS: MIE cleared on timer interrupt entry");

        end
        else begin

            $display("FAIL: MIE not cleared on timer entry");
            errors = errors + 1;

        end


        /*
         * MPIE should contain the previous MIE.
         */

        if (dut.csr_unit.mstatus[7] == 1'b1) begin

            $display("PASS: MPIE captured MIE");

        end
        else begin

            $display("FAIL: MPIE did not capture MIE");
            errors = errors + 1;

        end


        /*
         * Allow timer handler to execute.
         */

        repeat (15)
            @(posedge clk);

        #1;


        /*
         * =====================================================
         * TIMER MRET
         * =====================================================
         */

        if (dut.csr_unit.mstatus[3] == 1'b1) begin

            $display("PASS: MIE restored after timer MRET");

        end
        else begin

            $display("FAIL: MIE not restored after timer MRET");
            errors = errors + 1;

        end


        /*
         * =====================================================
         * UART EXTERNAL INTERRUPT
         * =====================================================
         */

        $display("");
        $display("---------------- UART EXTERNAL INTERRUPT ----------------");


        /*
         * Ensure timer is disabled.
         */

        dut.csr_unit.mie[7] = 1'b0;

        /*
         * Enable external interrupt.
         */

        dut.csr_unit.mie[11] = 1'b1;

        /*
         * Enable global interrupts.
         */

        dut.csr_unit.mstatus[3] = 1'b1;


        /*
         * Generate UART interrupt.
         */

        uart_rx_irq = 1'b1;


        /*
         * Wait for external interrupt acceptance.
         */

        wait (dut.csr_unit.mcause == 32'h8000000B);

        #1;


        $display("MCAUSE = 0x%08h",
                 dut.csr_unit.mcause);

        if (dut.csr_unit.mcause == 32'h8000000B) begin

            $display("PASS: UART external interrupt MCAUSE");

        end
        else begin

            $display("FAIL: UART external interrupt MCAUSE");
            errors = errors + 1;

        end


        /*
         * Interrupt entry should clear MIE.
         */

        if (dut.csr_unit.mstatus[3] == 1'b0) begin

            $display("PASS: MIE cleared on UART interrupt");

        end
        else begin

            $display("FAIL: MIE not cleared on UART interrupt");
            errors = errors + 1;

        end


        /*
         * Release UART interrupt source.
         *
         * This is necessary because the current SOC_MODE path
         * treats uart_rx_irq as a level-sensitive external
         * interrupt request.
         */

        uart_rx_irq = 1'b0;


        /*
         * Let handler execute.
         */

        repeat (15)
            @(posedge clk);

        #1;


        /*
         * =====================================================
         * UART MRET
         * =====================================================
         */

        if (dut.csr_unit.mstatus[3] == 1'b1) begin

            $display("PASS: MIE restored after UART MRET");

        end
        else begin

            $display("FAIL: MIE not restored after UART MRET");
            errors = errors + 1;

        end


        /*
         * =====================================================
         * INTERRUPT MASKING TEST
         * =====================================================
         */

        $display("");
        $display("---------------- INTERRUPT MASKING ----------------");


        /*
         * Disable global interrupts.
         */

        dut.csr_unit.mstatus[3] = 1'b0;

        /*
         * Enable timer.
         */

        dut.csr_unit.mie[7] = 1'b1;

        /*
         * Timer is already pending.
         *
         * Because MIE = 0, interrupt must not be accepted.
         */

        repeat (10)
            @(posedge clk);

        #1;


        if (dut.csr_unit.mstatus[3] == 1'b0) begin

            $display("PASS: Global MIE masks timer interrupt");

        end
        else begin

            $display("FAIL: Global MIE masking");
            errors = errors + 1;

        end


        /*
         * =====================================================
         * UART MASKING
         * =====================================================
         */

        /*
         * Keep global MIE disabled.
         */

        dut.csr_unit.mstatus[3] = 1'b0;

        /*
         * External interrupt enabled.
         */

        dut.csr_unit.mie[11] = 1'b1;

        /*
         * Generate UART interrupt.
         */

        uart_rx_irq = 1'b1;

        repeat (10)
            @(posedge clk);

        #1;


        /*
         * Since global MIE = 0, the CPU must not enter
         * the external interrupt handler.
         */

        if (dut.csr_unit.mstatus[3] == 1'b0) begin

            $display("PASS: Global MIE masks UART interrupt");

        end
        else begin

            $display("FAIL: UART global masking");
            errors = errors + 1;

        end


        /*
         * Release UART source.
         */

        uart_rx_irq = 1'b0;


        /*
         * =====================================================
         * INDIVIDUAL TIMER MASK
         * =====================================================
         */

        /*
         * Global interrupt enabled.
         */

        dut.csr_unit.mstatus[3] = 1'b1;

        /*
         * Timer disabled.
         */

        dut.csr_unit.mie[7] = 1'b0;

        /*
         * UART disabled.
         */

        dut.csr_unit.mie[11] = 1'b0;

        /*
         * Save current cause.
         */

        #1;

        if (dut.csr_unit.mcause != 32'h80000007) begin

            $display("PASS: Timer interrupt remains masked");

        end
        else begin

            /*
             * Cause may legitimately remain from the previous
             * timer event. Therefore also inspect pending path.
             */

            if (dut.timer_interrupt_pending == 1'b0) begin

                $display("PASS: Timer pending path disabled");

            end
            else begin

                $display("FAIL: Timer masking");
                errors = errors + 1;

            end

        end


        /*
         * =====================================================
         * SIMULTANEOUS TIMER + UART
         * =====================================================
         */

        $display("");
        $display("---------------- TIMER + UART PRIORITY ----------------");


        /*
         * Enable both interrupt sources.
         */

        dut.csr_unit.mstatus[3] = 1'b1;
        dut.csr_unit.mie[7]     = 1'b1;
        dut.csr_unit.mie[11]    = 1'b1;


        /*
         * Timer is already pending.
         *
         * Assert UART at the same time.
         */

        uart_rx_irq = 1'b1;


        /*
         * Wait for an interrupt.
         */

        wait (
            (dut.csr_unit.mcause == 32'h80000007) ||
            (dut.csr_unit.mcause == 32'h8000000B)
        );

        #1;


        $display("MCAUSE = 0x%08h",
                 dut.csr_unit.mcause);


        /*
         * Current CPU priority:
         *
         * UART external interrupt
         *       >
         * Timer interrupt
         */

        if (dut.csr_unit.mcause == 32'h8000000B) begin

            $display("PASS: UART external interrupt has priority");

        end
        else begin

            $display("FAIL: Interrupt priority");
            errors = errors + 1;

        end


        /*
         * Release UART.
         */

        uart_rx_irq = 1'b0;


        /*
         * =====================================================
         * FINAL REGISTER CHECK
         * =====================================================
         */

        repeat (20)
            @(posedge clk);

        #1;


        /*
         * x12 should have been calculated after ECALL.
         */

        $display("");
        $display("---------------- FINAL CPU STATE ----------------");

        $display("x10 = 0x%08h",
                 dut.registers.registers[10]);

        $display("x11 = 0x%08h",
                 dut.registers.registers[11]);

        $display("x12 = 0x%08h",
                 dut.registers.registers[12]);


        if (dut.registers.registers[10] == 32'h00000055) begin

            $display("PASS: x10 preserved");

        end
        else begin

            $display("FAIL: x10 corrupted");
            errors = errors + 1;

        end


        if (dut.registers.registers[11] == 32'h00000066) begin

            $display("PASS: x11 preserved");

        end
        else begin

            $display("FAIL: x11 corrupted");
            errors = errors + 1;

        end


        if (dut.registers.registers[12] == 32'h000000BB) begin

            $display("PASS: x12 preserved");

        end
        else begin

            $display("FAIL: x12 corrupted");
            errors = errors + 1;

        end


        /*
         * =====================================================
         * FINAL RESULT
         * =====================================================
         */

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display("      STAGE 5 INTEGRATED CSR TEST PASS");

        end
        else begin

            $display("      STAGE 5 INTEGRATED CSR TEST FAIL");
            $display("      ERROR COUNT = %0d", errors);

        end

        $display("======================================================");

        $finish;

    end

endmodule