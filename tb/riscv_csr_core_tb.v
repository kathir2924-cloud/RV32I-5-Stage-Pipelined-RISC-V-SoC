`timescale 1ns/1ps

module riscv_csr_core_tb;

    reg clk;
    reg rst;

    // =========================================================
    // DUT
    // =========================================================

    riscv_core #(
    .CSR_TEST(1'b1)
) dut (
    .clk(clk),
    .rst(rst)
);

    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    

    // =========================================================
    // OVERRIDE INSTRUCTION MEMORY
    // =========================================================
    //
    // The normal instruction_memory remains untouched.
    //
    // We temporarily provide our CSR test program directly
    // to the CPU instruction wire.
    //
    // =========================================================

    


    // =========================================================
    // TEST
    // =========================================================

    initial begin

        // -----------------------------------------------------
        // Initialize reset
        // -----------------------------------------------------

        rst = 1'b1;

        #20;

        rst = 1'b0;


        // -----------------------------------------------------
        // Initialize source registers
        //
        // x6 = 30
        // x1 = 10
        //
        // We directly initialize them for this isolated
        // integration test.
        // -----------------------------------------------------

        dut.registers.registers[6] = 32'd30;
        dut.registers.registers[1] = 32'd10;


        // -----------------------------------------------------
        // Run enough cycles for all CSR instructions to
        // propagate through the 5-stage pipeline.
        // -----------------------------------------------------

        #250;


        // =====================================================
        // RESULTS
        // =====================================================

        $display("");
        $display("==============================================");
        $display("          CSR CPU INTEGRATION TEST");
        $display("==============================================");


        // -----------------------------------------------------
        // CSRRW
        //
        // Initial mscratch = 0
        //
        // x5 should receive 0
        // mscratch should become 30
        // -----------------------------------------------------

        if (dut.registers.registers[5] == 32'd0)
            $display("PASS: CSRRW old CSR value -> x5");
        else
            $display("FAIL: CSRRW x5 = %h",
                     dut.registers.registers[5]);


        // -----------------------------------------------------
        // CSRRS
        //
        // old mscratch = 30
        //
        // x7 = 30
        //
        // 30 | 10 = 30
        // -----------------------------------------------------

        if (dut.registers.registers[7] == 32'd30)
            $display("PASS: CSRRS old CSR value -> x7");
        else
            $display("FAIL: CSRRS x7 = %h",
                     dut.registers.registers[7]);


        // -----------------------------------------------------
        // CSRRC
        //
        // old mscratch = 30
        //
        // x8 = 30
        //
        // 30 & ~10 = 20
        // -----------------------------------------------------

        if (dut.registers.registers[8] == 32'd30)
            $display("PASS: CSRRC old CSR value -> x8");
        else
            $display("FAIL: CSRRC x8 = %h",
                     dut.registers.registers[8]);


        // -----------------------------------------------------
        // CSRRWI
        //
        // old mscratch = 20
        //
        // x9 = 20
        //
        // mscratch = 5
        // -----------------------------------------------------

        if (dut.registers.registers[9] == 32'd20)
            $display("PASS: CSRRWI old CSR value -> x9");
        else
            $display("FAIL: CSRRWI x9 = %h",
                     dut.registers.registers[9]);


        // -----------------------------------------------------
        // CSRRSI
        //
        // old mscratch = 5
        //
        // x10 = 5
        //
        // 5 | 2 = 7
        // -----------------------------------------------------

        if (dut.registers.registers[10] == 32'd5)
            $display("PASS: CSRRSI old CSR value -> x10");
        else
            $display("FAIL: CSRRSI x10 = %h",
                     dut.registers.registers[10]);


        // -----------------------------------------------------
        // CSRRCI
        //
        // old mscratch = 7
        //
        // x11 = 7
        //
        // 7 & ~1 = 6
        // -----------------------------------------------------

        if (dut.registers.registers[11] == 32'd7)
            $display("PASS: CSRRCI old CSR value -> x11");
        else
            $display("FAIL: CSRRCI x11 = %h",
                     dut.registers.registers[11]);


        // =====================================================
        // FINAL RESULT
        // =====================================================

        if (
            dut.registers.registers[5]  == 32'd0  &&
            dut.registers.registers[7]  == 32'd30 &&
            dut.registers.registers[8]  == 32'd30 &&
            dut.registers.registers[9]  == 32'd20 &&
            dut.registers.registers[10] == 32'd5  &&
            dut.registers.registers[11] == 32'd7
        ) begin

            $display("");
            $display("***********************************************");
            $display("*                                             *");
            $display("*       CSR CPU INTEGRATION TEST PASS       *");
            $display("*                                             *");
            $display("***********************************************");

        end
        else begin

            $display("");
            $display("***********************************************");
            $display("*                                             *");
            $display("*       CSR CPU INTEGRATION TEST FAIL       *");
            $display("*                                             *");
            $display("***********************************************");

        end


        // -----------------------------------------------------
        // Display final registers
        // -----------------------------------------------------

        $display("");
        $display("Final CSR Test Registers:");
        $display("x5  = %h", dut.registers.registers[5]);
        $display("x7  = %h", dut.registers.registers[7]);
        $display("x8  = %h", dut.registers.registers[8]);
        $display("x9  = %h", dut.registers.registers[9]);
        $display("x10 = %h", dut.registers.registers[10]);
        $display("x11 = %h", dut.registers.registers[11]);

        $display("");
        $display("CSR CPU TEST COMPLETE");

        $finish;

    end

endmodule