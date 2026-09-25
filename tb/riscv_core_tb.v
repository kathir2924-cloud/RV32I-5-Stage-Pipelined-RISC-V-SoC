`timescale 1ns/1ps

module riscv_core_tb;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    reg clk;
    reg rst;

    // ============================================================
    // DUT
    // ============================================================

    riscv_core dut (
        .clk(clk),
        .rst(rst)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    always #5 clk = ~clk;

    // ============================================================
    // TEST CONTROL
    // ============================================================

    reg signed_tests_checked;

    // ============================================================
    // MAIN TEST
    // ============================================================

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        signed_tests_checked = 1'b0;

        // Waveform
        $dumpfile("riscv_full_regression.vcd");
        $dumpvars(0, riscv_core_tb);

        // Reset
        #12;
        rst = 1'b0;

        #10;

if (dut.id_valid !== 1'b1)
    $display("FAIL: IF/ID valid bit is not asserted");
else
    $display("PASS: IF/ID valid bit is asserted");

// Step 4C: Check ID/EX valid bit
if (dut.ex_valid !== 1'b1)
    $display("FAIL: ID/EX valid bit is not asserted");
else
    $display("PASS: ID/EX valid bit is asserted");

// Step 5C: Check EX/MEM valid bit
if (dut.mem_valid !== 1'b1)
    $display("FAIL: EX/MEM valid bit is not asserted");
else
    $display("PASS: EX/MEM valid bit is asserted");


// Step 6C: Check MEM/WB valid bit
if (dut.wb_valid !== 1'b1)
    $display("FAIL: MEM/WB valid bit is not asserted");
else
    $display("PASS: MEM/WB valid bit is asserted");

        // Allow complete program execution
        #1200;

        // ========================================================
        // FINAL REGISTER VALUES
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        FINAL REGISTER VALUES");
        $display("==============================================");

        $display("x1  = %0d", dut.registers.registers[1]);
        $display("x2  = %0d", dut.registers.registers[2]);
        $display("x3  = %0d", dut.registers.registers[3]);
        $display("x4  = %0d", dut.registers.registers[4]);
        $display("x5  = %0d", dut.registers.registers[5]);
        $display("x6  = %0d", dut.registers.registers[6]);
        $display("x7  = %0d", dut.registers.registers[7]);
        $display("x8  = %0d", dut.registers.registers[8]);
        $display("x9  = %0d", dut.registers.registers[9]);
        $display("x10 = %0d", dut.registers.registers[10]);
        $display("x11 = %0d", dut.registers.registers[11]);
        $display("x12 = %0d", dut.registers.registers[12]);
        $display("x13 = %0d", dut.registers.registers[13]);
        $display("x14 = %0d", dut.registers.registers[14]);
        $display("x15 = %0d", dut.registers.registers[15]);
        $display("x16 = %0d", dut.registers.registers[16]);
        $display("x17 = %h",  dut.registers.registers[17]);
        $display("x18 = %h",  dut.registers.registers[18]);
        $display("x19 = %0d", dut.registers.registers[19]);
        $display("x20 = %0d", dut.registers.registers[20]);
        $display("x21 = %0d", dut.registers.registers[21]);
        $display("x22 = %0d", dut.registers.registers[22]);
        $display("x23 = %0d", dut.registers.registers[23]);
        $display("x24 = %0d", dut.registers.registers[24]);
        $display("x25 = %0d", dut.registers.registers[25]);
        $display("x26 = %0d", dut.registers.registers[26]);
        $display("x27 = %0d", dut.registers.registers[27]);
        $display("x28 = %0d", dut.registers.registers[28]);
        $display("x29 = %0d", dut.registers.registers[29]);
        $display("x30 = %0d", dut.registers.registers[30]);
        $display("x31 = %0d", dut.registers.registers[31]);


        // ========================================================
        // BASIC INSTRUCTION TESTS
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        BASIC INSTRUCTION TESTS");
        $display("==============================================");

        if (dut.registers.registers[1] == 32'd10)
            $display("ADDI x1 PASS");
        else
            $display("ADDI x1 FAIL: got %0d",
                     dut.registers.registers[1]);

        if (dut.registers.registers[2] == 32'd20)
            $display("ADDI x2 PASS");
        else
            $display("ADDI x2 FAIL: got %0d",
                     dut.registers.registers[2]);

        if (dut.registers.registers[3] == 32'd30)
            $display("ADD PASS");
        else
            $display("ADD FAIL: got %0d",
                     dut.registers.registers[3]);

        if (dut.registers.registers[4] == 32'd10)
            $display("SUB PASS");
        else
            $display("SUB FAIL: got %0d",
                     dut.registers.registers[4]);

        if (dut.registers.registers[5] == 32'd0)
            $display("AND PASS");
        else
            $display("AND FAIL: got %0d",
                     dut.registers.registers[5]);

        if (dut.registers.registers[6] == 32'd30)
            $display("OR PASS");
        else
            $display("OR FAIL: got %0d",
                     dut.registers.registers[6]);

        if (dut.registers.registers[7] == 32'd30)
            $display("XOR PASS");
        else
            $display("XOR FAIL: got %0d",
                     dut.registers.registers[7]);


        // ========================================================
        // LOAD / STORE
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        LOAD / STORE TESTS");
        $display("==============================================");

        if (dut.registers.registers[8] == 32'd30)
            $display("LW PASS");
        else
            $display("LW FAIL: got %0d",
                     dut.registers.registers[8]);

        if (dut.registers.registers[9] == 32'd40)
            $display("LOAD-USE HAZARD + FORWARDING PASS");
        else
            $display("LOAD-USE HAZARD FAIL: got %0d",
                     dut.registers.registers[9]);


        // ========================================================
        // SLT / SLTU
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        SLT / SLTU TESTS");
        $display("==============================================");

        if (dut.registers.registers[10] == 32'd1)
            $display("SLT PASS");
        else
            $display("SLT FAIL: got %0d",
                     dut.registers.registers[10]);

        if (dut.registers.registers[11] == 32'd1)
            $display("SLTU PASS");
        else
            $display("SLTU FAIL: got %0d",
                     dut.registers.registers[11]);


        // ========================================================
        // BEQ
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        BEQ TEST");
        $display("==============================================");

        if (dut.registers.registers[12] == 32'd777)
            $display("BEQ NOT-TAKEN PASS");
        else
            $display("BEQ NOT-TAKEN FAIL: got %0d",
                     dut.registers.registers[12]);


        // ========================================================
        // JAL
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        JAL TEST");
        $display("==============================================");

        if (dut.registers.registers[13] == 32'd68)
            $display("JAL LINK PASS");
        else
            $display("JAL LINK FAIL: got %0d",
                     dut.registers.registers[13]);

        if (dut.registers.registers[14] == 32'd999)
            $display("JAL TARGET + FLUSH PASS");
        else
            $display("JAL TARGET + FLUSH FAIL: got %0d",
                     dut.registers.registers[14]);


        // ========================================================
        // JALR
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        JALR TEST");
        $display("==============================================");

        if (dut.registers.registers[15] == 32'd100)
            $display("JALR BASE REGISTER PASS");
        else
            $display("JALR BASE REGISTER FAIL: got %0d",
                     dut.registers.registers[15]);

        if (dut.registers.registers[16] == 32'd999)
            $display("JALR TARGET + FLUSH PASS");
        else
            $display("JALR TARGET + FLUSH FAIL: got %0d",
                     dut.registers.registers[16]);


        // ========================================================
        // LUI
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        LUI TEST");
        $display("==============================================");

        if (dut.registers.registers[17] == 32'h12345000)
            $display("LUI PASS");
        else
            $display("LUI FAIL: got %h",
                     dut.registers.registers[17]);


        // ========================================================
        // AUIPC
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        AUIPC TEST");
        $display("==============================================");

        if (dut.registers.registers[18] == 32'h00001070)
            $display("AUIPC PASS");
        else
            $display("AUIPC FAIL: got %h",
                     dut.registers.registers[18]);


        // ========================================================
        // CONDITIONAL BRANCHES
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        CONDITIONAL BRANCH TESTS");
        $display("==============================================");

        if (dut.registers.registers[19] == 32'd2)
            $display("BNE TAKEN + FLUSH PASS");
        else
            $display("BNE FAIL: got %0d",
                     dut.registers.registers[19]);

        if (dut.registers.registers[20] == 32'd2)
            $display("BLT TAKEN + FLUSH PASS");
        else
            $display("BLT FAIL: got %0d",
                     dut.registers.registers[20]);

        if (dut.registers.registers[21] == 32'd2)
            $display("BGE TAKEN + FLUSH PASS");
        else
            $display("BGE FAIL: got %0d",
                     dut.registers.registers[21]);

        if (dut.registers.registers[22] == 32'd2)
            $display("BLTU TAKEN + FLUSH PASS");
        else
            $display("BLTU FAIL: got %0d",
                     dut.registers.registers[22]);

        if (dut.registers.registers[23] == 32'd2)
            $display("BGEU TAKEN + FLUSH PASS");
        else
            $display("BGEU FAIL: got %0d",
                     dut.registers.registers[23]);


        // ========================================================
        // I-TYPE ALU TESTS
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        I-TYPE ALU TESTS");
        $display("==============================================");

        if (dut.registers.registers[24] == 32'd15)
            $display("ADDI I-TYPE PASS");
        else
            $display("ADDI I-TYPE FAIL: got %0d",
                     dut.registers.registers[24]);

        if (dut.registers.registers[25] == 32'd2)
            $display("ANDI PASS");
        else
            $display("ANDI FAIL: got %0d",
                     dut.registers.registers[25]);

        if (dut.registers.registers[26] == 32'd15)
            $display("ORI PASS");
        else
            $display("ORI FAIL: got %0d",
                     dut.registers.registers[26]);

        if (dut.registers.registers[27] == 32'd5)
            $display("XORI PASS");
        else
            $display("XORI FAIL: got %0d",
                     dut.registers.registers[27]);

        if (dut.registers.registers[28] == 32'd1)
            $display("SLTI PASS");
        else
            $display("SLTI FAIL: got %0d",
                     dut.registers.registers[28]);

        if (dut.registers.registers[29] == 32'd1)
            $display("SLTIU PASS");
        else
            $display("SLTIU FAIL: got %0d",
                     dut.registers.registers[29]);

        if (dut.registers.registers[30] == 32'd40)
            $display("SLLI PASS");
        else
            $display("SLLI FAIL: got %0d",
                     dut.registers.registers[30]);

        if (dut.registers.registers[31] == 32'd5)
            $display("SRLI PASS");
        else
            $display("SRLI FAIL: got %0d",
                     dut.registers.registers[31]);


        // ========================================================
        // FINAL REGRESSION
        // ========================================================

        $display("");
        $display("==============================================");
        $display("        FINAL REGRESSION CHECK");
        $display("==============================================");

        if (
            // Basic
            dut.registers.registers[1]  == 32'd10 &&
            dut.registers.registers[2]  == 32'd20 &&
            dut.registers.registers[3]  == 32'd30 &&
            dut.registers.registers[4]  == 32'd10 &&
            dut.registers.registers[5]  == 32'd0 &&
            dut.registers.registers[6]  == 32'd30 &&
            dut.registers.registers[7]  == 32'd30 &&

            // Load/store
            dut.registers.registers[8]  == 32'd30 &&
            dut.registers.registers[9]  == 32'd40 &&

            // Comparison
            dut.registers.registers[10] == 32'd1 &&
            dut.registers.registers[11] == 32'd1 &&

            // BEQ/JAL/JALR
            dut.registers.registers[12] == 32'd777 &&
            dut.registers.registers[13] == 32'd68 &&
            dut.registers.registers[14] == 32'd999 &&
            dut.registers.registers[15] == 32'd100 &&
            dut.registers.registers[16] == 32'd999 &&

            // LUI/AUIPC
            dut.registers.registers[17] == 32'h12345000 &&
            dut.registers.registers[18] == 32'h00001070 &&

            // Branches
            dut.registers.registers[19] == 32'd2 &&
            dut.registers.registers[20] == 32'd2 &&
            dut.registers.registers[21] == 32'd2 &&
            dut.registers.registers[22] == 32'd2 &&
            dut.registers.registers[23] == 32'd2 &&

            // I-type
            dut.registers.registers[24] == 32'd15 &&
            dut.registers.registers[25] == 32'd2 &&
            dut.registers.registers[26] == 32'd15 &&
            dut.registers.registers[27] == 32'd5 &&
            dut.registers.registers[28] == 32'd1 &&
            dut.registers.registers[29] == 32'd1 &&
            dut.registers.registers[30] == 32'd40 &&
            dut.registers.registers[31] == 32'd5

        ) begin

            $display("");
            $display("***********************************************");
            $display("*                                             *");
            $display("*       FULL PROCESSOR REGRESSION PASS       *");
            $display("*                                             *");
            $display("***********************************************");
            $display("");

        end
        else begin

            $display("");
            $display("***********************************************");
            $display("*                                             *");
            $display("*       FULL PROCESSOR REGRESSION FAIL       *");
            $display("*                                             *");
            $display("***********************************************");
            $display("");

        end
// ============================================================
// PERFORMANCE COUNTER CHECK
// ============================================================

$display("");
$display("==============================================");
$display("       PERFORMANCE COUNTER RESULTS");
$display("==============================================");

$display("Cycle Count       = %0d", dut.cycle_count);
$display("Instructions Retired = %0d", dut.instret_count);
$display("Stall Cycles      = %0d", dut.stall_count);

if (dut.instret_count > 0)
    $display("CPI               = %0f",
             $itor(dut.cycle_count) / $itor(dut.instret_count));
else
    $display("CPI               = N/A");

$display("==============================================");
        $finish;

    end


    // ============================================================
    // SIGNED / UNSIGNED EDGE-CASE VERIFICATION
    // ============================================================
    //
    // We check the ALU while the instruction is in EX.
    // This avoids the later restoration instructions overwriting
    // x19-x23.
    //
    // Program:
    //
    // PC 216 : ADDI  x19,x0,-8
    // PC 220 : SLTI  x20,x19,0
    // PC 224 : SLTIU x21,x19,0
    // PC 228 : SRAI  x22,x19,2
    // PC 232 : SRLI  x23,x19,2
    //
    // Expected:
    //
    // x19 = FFFFFFF8
    // SLTI  = 00000001
    // SLTIU = 00000000
    // SRAI  = FFFFFFFE
    // SRLI  = 3FFFFFFE
    //
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            // ----------------------------------------------------
            // SLTI
            // ----------------------------------------------------

            if (dut.ex_pc == 32'd220) begin

                if (dut.alu_result == 32'd1)
                    $display("SLTI NEGATIVE OPERAND PASS");
                else
                    $display(
                        "SLTI NEGATIVE OPERAND FAIL: ALU=%h",
                        dut.alu_result
                    );

            end


            // ----------------------------------------------------
            // SLTIU
            // ----------------------------------------------------

            if (dut.ex_pc == 32'd224) begin

                if (dut.alu_result == 32'd0)
                    $display("SLTIU NEGATIVE OPERAND PASS");
                else
                    $display(
                        "SLTIU NEGATIVE OPERAND FAIL: ALU=%h",
                        dut.alu_result
                    );

            end


            // ----------------------------------------------------
            // SRAI
            // ----------------------------------------------------

            if (dut.ex_pc == 32'd228) begin

                if (dut.alu_result == 32'hFFFFFFFE)
                    $display("SRAI SIGN EXTENSION PASS");
                else
                    $display(
                        "SRAI SIGN EXTENSION FAIL: ALU=%h",
                        dut.alu_result
                    );

            end


            // ----------------------------------------------------
            // SRLI
            // ----------------------------------------------------

            if (dut.ex_pc == 32'd232) begin

                if (dut.alu_result == 32'h3FFFFFFE)
                    $display("SRLI ZERO FILL PASS");
                else
                    $display(
                        "SRLI ZERO FILL FAIL: ALU=%h",
                        dut.alu_result
                    );

            end

        end

    end


    // ============================================================
    // PIPELINE MONITOR
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            $display(
                "TIME=%0t | PC=%h | INSTR=%h | EX_PC=%h | ALU_A=%h | ALU_B=%h | ALU_RESULT=%h | FWD_A=%b | FWD_B=%b | MEM_RD=%h | WB_RD=%h",
                $time,
                dut.pc,
                dut.instruction,
                dut.ex_pc,
                dut.alu_input_a,
                dut.alu_input_b,
                dut.alu_result,
                dut.forward_a,
                dut.forward_b,
                dut.mem_rd,
                dut.wb_rd
            );

        end

    end

    always @(posedge clk) begin

    if (dut.timer_interrupt_pending) begin

        $display(
            "TIMER PENDING | time=%0t | PC=%08h | EX_PC=%08h | EX_VALID=%b | INTERRUPT_TAKEN=%b",
            $time,
            dut.pc,
            dut.ex_pc,
            dut.ex_valid,
            dut.interrupt_taken
        );

    end

end

endmodule