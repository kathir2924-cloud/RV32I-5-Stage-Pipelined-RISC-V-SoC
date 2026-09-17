`timescale 1ns/1ps

module jump_unit_tb;

reg [31:0] pc;
reg [31:0] rs1_value;
reg [31:0] immediate;
reg        jump;
reg        jalr;

wire [31:0] target_address;
wire        jump_taken;

jump_unit dut (
    .pc(pc),
    .rs1_value(rs1_value),
    .immediate(immediate),
    .jump(jump),
    .jalr(jalr),
    .target_address(target_address),
    .jump_taken(jump_taken)
);

initial begin

    $display("======================================");
    $display("          JUMP UNIT TEST");
    $display("======================================");

    // ------------------------------------------------
    // Test 1: No jump
    // ------------------------------------------------

    pc = 32'd100;
    rs1_value = 32'd200;
    immediate = 32'd20;
    jump = 1'b0;
    jalr = 1'b0;

    #10;

    $display("Test 1: No Jump");
    $display("Jump = %b | JALR = %b | Target = %d | Taken = %b",
             jump, jalr, target_address, jump_taken);

    if (jump_taken == 1'b0)
        $display("PASS");
    else
        $display("FAIL");


    // ------------------------------------------------
    // Test 2: JAL
    // ------------------------------------------------

    pc = 32'd100;
    rs1_value = 32'd200;
    immediate = 32'd40;
    jump = 1'b1;
    jalr = 1'b0;

    #10;

    $display("Test 2: JAL");
    $display("PC = %d | Immediate = %d | Target = %d | Taken = %b",
             pc, immediate, target_address, jump_taken);

    if (target_address == 32'd140 &&
        jump_taken == 1'b1)
        $display("PASS");
    else
        $display("FAIL");


    // ------------------------------------------------
    // Test 3: JALR
    // ------------------------------------------------

    pc = 32'd100;
    rs1_value = 32'd200;
    immediate = 32'd40;
    jump = 1'b1;
    jalr = 1'b1;

    #10;

    $display("Test 3: JALR");
    $display("RS1 = %d | Immediate = %d | Target = %d | Taken = %b",
             rs1_value, immediate, target_address, jump_taken);

    if (target_address == 32'd240 &&
        jump_taken == 1'b1)
        $display("PASS");
    else
        $display("FAIL");


    // ------------------------------------------------
    // Test 4: JALR alignment
    // ------------------------------------------------

    pc = 32'd100;
    rs1_value = 32'd201;
    immediate = 32'd40;
    jump = 1'b1;
    jalr = 1'b1;

    #10;

    $display("Test 4: JALR Alignment");
    $display("RS1 = %d | Immediate = %d | Target = %d",
             rs1_value, immediate, target_address);

    if (target_address == 32'd240)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule