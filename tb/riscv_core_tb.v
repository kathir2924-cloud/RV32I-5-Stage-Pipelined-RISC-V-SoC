`timescale 1ns/1ps

module riscv_core_tb;

reg clk;
reg rst;

riscv_core dut (
    .clk(clk),
    .rst(rst)
);

always #5 clk = ~clk;

initial begin

    $dumpfile("riscv_full_regression.vcd");
    $dumpvars(0, riscv_core_tb);

    clk = 0;
    rst = 1;

    #12;

    rst = 0;

    // Allow entire regression to complete
    #1200;

    $display("");
    $display("==============================================");
    $display("       RISC-V FULL PROCESSOR REGRESSION");
    $display("==============================================");

    $display("x1  = %d", dut.registers.registers[1]);
    $display("x2  = %d", dut.registers.registers[2]);
    $display("x3  = %d", dut.registers.registers[3]);
    $display("x4  = %d", dut.registers.registers[4]);
    $display("x5  = %d", dut.registers.registers[5]);
    $display("x6  = %d", dut.registers.registers[6]);
    $display("x7  = %d", dut.registers.registers[7]);
    $display("x8  = %d", dut.registers.registers[8]);
    $display("x9  = %d", dut.registers.registers[9]);
    $display("x10 = %d", dut.registers.registers[10]);
    $display("x11 = %d", dut.registers.registers[11]);
    $display("x12 = %d", dut.registers.registers[12]);
    $display("x13 = %d", dut.registers.registers[13]);
    $display("x14 = %d", dut.registers.registers[14]);
    $display("x15 = %d", dut.registers.registers[15]);
    $display("x16 = %d", dut.registers.registers[16]);
    $display("x17 = %h", dut.registers.registers[17]);
$display("x18 = %h", dut.registers.registers[18]);

    $display("----------------------------------------------");

    // =============================================================
    // ADDI
    // =============================================================

    if (dut.registers.registers[1] == 10)
        $display("ADDI x1 PASS");
    else
        $display("ADDI x1 FAIL");

    if (dut.registers.registers[2] == 20)
        $display("ADDI x2 PASS");
    else
        $display("ADDI x2 FAIL");


    // =============================================================
    // R-TYPE
    // =============================================================

    if (dut.registers.registers[3] == 30)
        $display("ADD PASS");
    else
        $display("ADD FAIL");

    if (dut.registers.registers[4] == 10)
        $display("SUB PASS");
    else
        $display("SUB FAIL");

    if (dut.registers.registers[5] == 0)
        $display("AND PASS");
    else
        $display("AND FAIL");

    if (dut.registers.registers[6] == 30)
        $display("OR PASS");
    else
        $display("OR FAIL");

    if (dut.registers.registers[7] == 30)
        $display("XOR PASS");
    else
        $display("XOR FAIL");


    // =============================================================
    // LOAD / STORE
    // =============================================================

    if (dut.registers.registers[8] == 30)
        $display("LW/SW PASS");
    else
        $display("LW/SW FAIL");


    // =============================================================
    // LOAD-USE HAZARD + FORWARDING
    // =============================================================

    if (dut.registers.registers[9] == 40)
        $display("LOAD-USE HAZARD + FORWARDING PASS");
    else
        $display("LOAD-USE HAZARD + FORWARDING FAIL");


    // =============================================================
    // SLT / SLTU
    // =============================================================

    if (dut.registers.registers[10] == 1)
        $display("SLT PASS");
    else
        $display("SLT FAIL");

    if (dut.registers.registers[11] == 1)
        $display("SLTU PASS");
    else
        $display("SLTU FAIL");


    // =============================================================
    // BEQ
    // =============================================================

    if (dut.registers.registers[12] == 777)
        $display("BEQ NOT-TAKEN PASS");
    else
        $display("BEQ NOT-TAKEN FAIL");


    // =============================================================
    // JAL
    // =============================================================

    if (dut.registers.registers[13] == 68)
        $display("JAL LINK PASS");
    else
        $display("JAL LINK FAIL");

    if (dut.registers.registers[14] == 999)
        $display("JAL TARGET + FLUSH PASS");
    else
        $display("JAL TARGET + FLUSH FAIL");


    // =============================================================
    // JALR
    // =============================================================

    if (dut.registers.registers[15] == 100)
        $display("JALR SOURCE PASS");
    else
        $display("JALR SOURCE FAIL");

    if (dut.registers.registers[16] == 999)
        $display("JALR TARGET + FLUSH PASS");
    else
        $display("JALR TARGET + FLUSH FAIL");

            // =============================================================
    // LUI / AUIPC
    // =============================================================

    if (dut.registers.registers[17] == 32'h12345000)
        $display("LUI PASS");
    else
        $display("LUI FAIL: Expected 12345000, Got %h",
                 dut.registers.registers[17]);

    if (dut.registers.registers[18] == 32'h00001070)
        $display("AUIPC PASS");
    else
        $display("AUIPC FAIL: Expected 00001070, Got %h",
                 dut.registers.registers[18]);


    // =============================================================
    // OVERALL
    // =============================================================

    if ((dut.registers.registers[1]  == 10) &&
        (dut.registers.registers[2]  == 20) &&
        (dut.registers.registers[3]  == 30) &&
        (dut.registers.registers[4]  == 10) &&
        (dut.registers.registers[5]  == 0) &&
        (dut.registers.registers[6]  == 30) &&
        (dut.registers.registers[7]  == 30) &&
        (dut.registers.registers[8]  == 30) &&
        (dut.registers.registers[9]  == 40) &&
        (dut.registers.registers[10] == 1) &&
        (dut.registers.registers[11] == 1) &&
        (dut.registers.registers[12] == 777) &&
        (dut.registers.registers[13] == 68) &&
        (dut.registers.registers[14] == 999) &&
        (dut.registers.registers[15] == 100) &&
                (dut.registers.registers[16] == 999) &&
        (dut.registers.registers[17] == 32'h12345000) &&
        (dut.registers.registers[18] == 32'h00001070))
    begin
        $display("");
        $display("****************************************");
        $display("      FULL PROCESSOR REGRESSION PASS");
        $display("****************************************");
    end
    else
    begin
        $display("");
        $display("****************************************");
        $display("      FULL PROCESSOR REGRESSION FAIL");
        $display("****************************************");
    end

    $display("==============================================");

    $finish;

end


// ===============================================================
// Processor monitor
// ===============================================================

always @(posedge clk) begin

    #1;

    $display("");
    $display(
        "Time=%0t | PC=%h | Instruction=%h | EX_PC=%h",
        $time,
        dut.pc,
        dut.instruction,
        dut.ex_pc
    );

    $display(
        "       EX: rs1=%d rs2=%d rd=%d | func3=%b func7=%b | ALU_OP=%b ALU_CTRL=%b",
        dut.ex_rs1,
        dut.ex_rs2,
        dut.ex_rd,
        dut.ex_func3,
        dut.ex_func7,
        dut.ex_alu_op,
        dut.alu_operation
    );

    $display(
        "       FWD: A=%b B=%b | OriginalA=%h OriginalB=%h | ForwardedA=%h ForwardedB=%h",
        dut.forward_a,
        dut.forward_b,
        dut.ex_read_data1,
        dut.ex_read_data2,
        dut.forwarded_a,
        dut.forwarded_b
    );

    $display(
        "       ALU: InputA=%h InputB=%h Result=%h",
        dut.alu_input_a,
        dut.alu_input_b,
        dut.alu_result
    );

    $display(
        "       MEM/WB: MEM_RD=%d MEM_WE=%b | WB_RD=%d WB_WE=%b | WB_DATA=%h",
        dut.mem_rd,
        dut.mem_reg_write,
        dut.wb_rd,
        dut.wb_reg_write,
        dut.write_back_data
    );

    $display(
        "       Control: Branch=%b Taken=%b Jump=%b JALR=%b",
        dut.ex_branch,
        dut.branch_taken,
        dut.ex_jump,
        dut.ex_jalr
    );

end

endmodule