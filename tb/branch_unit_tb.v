`timescale 1ns/1ps

module branch_unit_tb;

reg [31:0] rs1_value;
reg [31:0] rs2_value;
reg [31:0] pc;
reg [31:0] immediate;

reg branch;
reg jump;

reg [2:0] func3;

wire branch_taken;
wire [31:0] target_address;

branch_unit dut (
    .rs1_value(rs1_value),
    .rs2_value(rs2_value),
    .pc(pc),
    .immediate(immediate),

    .branch(branch),
    .jump(jump),

    .func3(func3),

    .branch_taken(branch_taken),
    .target_address(target_address)
);

initial begin

    pc = 32'd100;
    immediate = 32'd20;

    branch = 1'b0;
    jump = 1'b0;

    rs1_value = 32'd10;
    rs2_value = 32'd10;

    func3 = 3'b000;

    // ------------------------------------------------
    // Test 1: BEQ - taken
    // ------------------------------------------------

    branch = 1'b1;
    func3 = 3'b000;

    #10;


    // ------------------------------------------------
    // Test 2: BEQ - not taken
    // ------------------------------------------------

    rs2_value = 32'd20;

    #10;


    // ------------------------------------------------
    // Test 3: BNE - taken
    // ------------------------------------------------

    func3 = 3'b001;

    #10;


    // ------------------------------------------------
    // Test 4: BNE - not taken
    // ------------------------------------------------

    rs2_value = 32'd10;

    #10;


    // ------------------------------------------------
    // Test 5: BLT - taken
    // ------------------------------------------------

    rs1_value = 32'd5;
    rs2_value = 32'd10;
    func3 = 3'b100;

    #10;


    // ------------------------------------------------
    // Test 6: BGE - taken
    // ------------------------------------------------

    rs1_value = 32'd10;
    rs2_value = 32'd5;
    func3 = 3'b101;

    #10;


    // ------------------------------------------------
    // Test 7: BLTU - taken
    // ------------------------------------------------

    rs1_value = 32'd5;
    rs2_value = 32'd10;
    func3 = 3'b110;

    #10;


    // ------------------------------------------------
    // Test 8: BGEU - taken
    // ------------------------------------------------

    rs1_value = 32'd10;
    rs2_value = 32'd5;
    func3 = 3'b111;

    #10;


    // ------------------------------------------------
    // Test 9: JAL
    // ------------------------------------------------

    branch = 1'b0;
    jump = 1'b1;

    pc = 32'd200;
    immediate = 32'd40;

    #10;


    // ------------------------------------------------
    // Test 10: No branch / jump
    // ------------------------------------------------

    jump = 1'b0;

    #10;

    $finish;

end

initial begin

    $monitor(
        "Time=%0t | PC=%d | RS1=%d | RS2=%d | Imm=%d | Branch=%b | Jump=%b | Func3=%b | Taken=%b | Target=%d",
        $time,
        pc,
        rs1_value,
        rs2_value,
        immediate,
        branch,
        jump,
        func3,
        branch_taken,
        target_address
    );

end

initial begin

    $dumpfile("branch_unit.vcd");
    $dumpvars(0, branch_unit_tb);

end

endmodule