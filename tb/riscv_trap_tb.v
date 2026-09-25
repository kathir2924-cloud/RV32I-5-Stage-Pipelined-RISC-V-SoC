`timescale 1ns/1ps

module riscv_trap_tb;

    // =========================================================
    // CLOCK / RESET
    // =========================================================

    reg clk;
    reg rst;


    // =========================================================
    // DUT
    // =========================================================

    riscv_core #(
        .CSR_TEST  (1'b0),
        .TRAP_TEST (1'b1)
    ) dut (
        .clk (clk),
        .rst (rst)
    );


    // =========================================================
    // CLOCK GENERATION
    // 10 ns clock period
    // =========================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // =========================================================
    // TRAP TEST
    // =========================================================

    initial begin

        // -----------------------------------------------------
        // Reset
        // -----------------------------------------------------

        rst = 1'b1;

        #20;

        rst = 1'b0;


        // -----------------------------------------------------
        // Allow processor to execute
        // -----------------------------------------------------

        #1000;


        // =====================================================
        // DISPLAY RESULTS
        // =====================================================

        $display("");
        $display("========================================");
        $display("       RISC-V TRAP TEST");
        $display("========================================");


        // =====================================================
        // MTVEC
        // =====================================================

        $display(
            "mtvec  = %h",
            dut.csr_unit.mtvec_value
        );


        // =====================================================
        // MEPC
        // =====================================================

        $display(
            "mepc   = %h",
            dut.csr_unit.mepc_value
        );


        // =====================================================
        // MCAUSE
        // =====================================================

        $display(
            "mcause = %h",
            dut.csr_unit.mcause
        );


        // =====================================================
        // MTVAL
        // =====================================================

        $display(
            "mtval  = %h",
            dut.csr_unit.mtval
        );


        // =====================================================
        // GENERAL PURPOSE REGISTERS
        // =====================================================

        $display(
            "x5     = %h",
            dut.registers.registers[5]
        );

        $display(
            "x6     = %h",
            dut.registers.registers[6]
        );

        $display(
            "x7     = %h",
            dut.registers.registers[7]
        );


        // =====================================================
        // CHECK MTVEC
        // =====================================================

        if (dut.csr_unit.mtvec_value == 32'h00000100)

            $display("PASS: MTVEC = 0x100");

        else

            $display(
                "FAIL: MTVEC expected 0x100, got %h",
                dut.csr_unit.mtvec_value
            );


        // =====================================================
        // CHECK MCAUSE
        // ECALL = exception cause 11
        // =====================================================

        if (dut.csr_unit.mcause == 32'd11)

            $display("PASS: ECALL cause = 11");

        else

            $display(
                "FAIL: ECALL cause expected 11, got %h",
                dut.csr_unit.mcause
            );


        // =====================================================
        // CHECK MEPC
        // ECALL is at address 0x08
        // =====================================================

        if (dut.csr_unit.mepc_value == 32'h00000008)

            $display("PASS: MEPC = ECALL PC");

        else

            $display(
                "FAIL: MEPC expected 0x00000008, got %h",
                dut.csr_unit.mepc_value
            );


        // =====================================================
        // CHECK TRAP HANDLER
        //
        // x5 should contain MCAUSE
        // =====================================================

        if (dut.registers.registers[5] == 32'd11)

            $display("PASS: Trap handler read MCAUSE");

        else

            $display(
                "FAIL: Trap handler MCAUSE expected 11, got %h",
                dut.registers.registers[5]
            );


        // =====================================================
        // CHECK TRAP HANDLER
        //
        // x6 should contain MEPC
        // =====================================================

        if (dut.registers.registers[6] == 32'h00000008)

            $display("PASS: Trap handler read MEPC");

        else

            $display(
                "FAIL: Trap handler MEPC expected 0x00000008, got %h",
                dut.registers.registers[6]
            );


        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("");
        $display("========================================");
        $display("          TRAP TEST COMPLETE");
        $display("========================================");


        // -----------------------------------------------------
        // End simulation
        // -----------------------------------------------------
$display("DEBUG PC        = %08h", dut.pc);
$display("DEBUG ID INST   = %08h", dut.id_instruction);
$display("DEBUG EX PC     = %08h", dut.ex_pc);
$display("DEBUG EX INST   = %08h", dut.ex_instruction);
$display("DEBUG ID TRAP   = %b", dut.trap_enter);
$display("DEBUG EX TRAP   = %b", dut.ex_trap_enter);
$display("DEBUG EX CAUSE  = %0d", dut.ex_trap_cause);

$finish;

      


    end

// ============================================================
// TRAP DEBUG TRACE
// ============================================================
// ============================================================
// TRAP DEBUG TRACE
// ============================================================
// ============================================================
// FIRST 20 ACTIVE CLOCK DEBUG
// ============================================================

integer debug_count;

initial begin
    debug_count = 0;
end

always @(posedge clk) begin

    if (!rst && debug_count < 20) begin

        $display(
            "DEBUG %0d | T=%0t | PC=%08h | ID=%08h | EX_PC=%08h | EX_INST=%08h | ID_TRAP=%b | EX_TRAP=%b | CAUSE=%0d",
            debug_count,
            $time,
            dut.pc,
            dut.id_instruction,
            dut.ex_pc,
            dut.ex_instruction,
            dut.trap_enter,
            dut.ex_trap_enter,
            dut.ex_trap_cause
        );

        debug_count = debug_count + 1;

    end

end
    // =========================================================
    // WAVEFORM DUMP
    // =========================================================

    initial begin

        $dumpfile("riscv_trap.vcd");

        $dumpvars(0, riscv_trap_tb);

    end

endmodule