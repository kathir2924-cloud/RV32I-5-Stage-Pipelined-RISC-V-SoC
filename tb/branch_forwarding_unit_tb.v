`timescale 1ns/1ps

module branch_forwarding_unit_tb;

reg [4:0] branch_rs1;
reg [4:0] branch_rs2;

reg [31:0] original_rs1_value;
reg [31:0] original_rs2_value;

reg [4:0] mem_rd;
reg       mem_reg_write;
reg [31:0] mem_value;

reg [4:0] wb_rd;
reg       wb_reg_write;
reg [31:0] wb_value;

wire [31:0] branch_rs1_forwarded;
wire [31:0] branch_rs2_forwarded;


branch_forwarding_unit dut (

    .branch_rs1(branch_rs1),
    .branch_rs2(branch_rs2),

    .original_rs1_value(original_rs1_value),
    .original_rs2_value(original_rs2_value),

    .mem_rd(mem_rd),
    .mem_reg_write(mem_reg_write),
    .mem_value(mem_value),

    .wb_rd(wb_rd),
    .wb_reg_write(wb_reg_write),
    .wb_value(wb_value),

    .branch_rs1_forwarded(branch_rs1_forwarded),
    .branch_rs2_forwarded(branch_rs2_forwarded)

);


initial begin

    $display("======================================");
    $display("     BRANCH FORWARDING UNIT TEST");
    $display("======================================");


    // ============================================================
    // TEST 1: No forwarding
    // ============================================================

    branch_rs1 = 5'd1;
    branch_rs2 = 5'd2;

    original_rs1_value = 32'd10;
    original_rs2_value = 32'd20;

    mem_rd = 5'd5;
    mem_reg_write = 1'b0;
    mem_value = 32'd100;

    wb_rd = 5'd6;
    wb_reg_write = 1'b0;
    wb_value = 32'd200;

    #10;

    $display("Test 1: No Forwarding");
    $display("RS1 = %d | RS2 = %d",
             branch_rs1_forwarded,
             branch_rs2_forwarded);

    if (branch_rs1_forwarded == 10 &&
        branch_rs2_forwarded == 20)
        $display("PASS");
    else
        $display("FAIL");


    // ============================================================
    // TEST 2: Forward RS1 from EX/MEM
    // ============================================================

    branch_rs1 = 5'd1;
    branch_rs2 = 5'd2;

    original_rs1_value = 32'd10;
    original_rs2_value = 32'd20;

    mem_rd = 5'd1;
    mem_reg_write = 1'b1;
    mem_value = 32'd100;

    wb_rd = 5'd6;
    wb_reg_write = 1'b0;
    wb_value = 32'd200;

    #10;

    $display("Test 2: EX/MEM -> RS1");
    $display("RS1 = %d | RS2 = %d",
             branch_rs1_forwarded,
             branch_rs2_forwarded);

    if (branch_rs1_forwarded == 100 &&
        branch_rs2_forwarded == 20)
        $display("PASS");
    else
        $display("FAIL");


    // ============================================================
    // TEST 3: Forward RS2 from MEM/WB
    // ============================================================

    mem_rd = 5'd7;
    mem_reg_write = 1'b0;

    wb_rd = 5'd2;
    wb_reg_write = 1'b1;
    wb_value = 32'd200;

    #10;

    $display("Test 3: MEM/WB -> RS2");
    $display("RS1 = %d | RS2 = %d",
             branch_rs1_forwarded,
             branch_rs2_forwarded);

    if (branch_rs1_forwarded == 10 &&
        branch_rs2_forwarded == 200)
        $display("PASS");
    else
        $display("FAIL");


    // ============================================================
    // TEST 4: Forward both operands
    // ============================================================

    mem_rd = 5'd1;
    mem_reg_write = 1'b1;
    mem_value = 50;

    wb_rd = 5'd2;
    wb_reg_write = 1'b1;
    wb_value = 60;

    #10;

    $display("Test 4: Forward Both");
    $display("RS1 = %d | RS2 = %d",
             branch_rs1_forwarded,
             branch_rs2_forwarded);

    if (branch_rs1_forwarded == 50 &&
        branch_rs2_forwarded == 60)
        $display("PASS");
    else
        $display("FAIL");


    // ============================================================
    // TEST 5: EX/MEM priority over MEM/WB
    // ============================================================

    mem_rd = 5'd1;
    mem_reg_write = 1'b1;
    mem_value = 500;

    wb_rd = 5'd1;
    wb_reg_write = 1'b1;
    wb_value = 900;

    #10;

    $display("Test 5: EX/MEM Priority");
    $display("RS1 = %d", branch_rs1_forwarded);

    if (branch_rs1_forwarded == 500)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule