`timescale 1ns/1ps

module pc_next_logic_tb;

reg  [31:0] pc;
reg  [31:0] target_address;
reg         control_transfer;

wire [31:0] next_pc;

pc_next_logic dut (
    .pc(pc),
    .target_address(target_address),
    .control_transfer(control_transfer),
    .next_pc(next_pc)
);

initial begin

    $display("======================================");
    $display("       PC NEXT LOGIC TEST");
    $display("======================================");

    // Test 1: Normal instruction
    pc = 32'd100;
    target_address = 32'd200;
    control_transfer = 1'b0;

    #10;

    $display("Test 1: Normal");
    $display("PC = %d | Target = %d | Control = %b | Next PC = %d",
             pc, target_address, control_transfer, next_pc);

    if (next_pc == 32'd104)
        $display("PASS");
    else
        $display("FAIL");


    // Test 2: Branch taken
    pc = 32'd100;
    target_address = 32'd140;
    control_transfer = 1'b1;

    #10;

    $display("Test 2: Branch Taken");
    $display("PC = %d | Target = %d | Control = %b | Next PC = %d",
             pc, target_address, control_transfer, next_pc);

    if (next_pc == 32'd140)
        $display("PASS");
    else
        $display("FAIL");


    // Test 3: Another normal instruction
    pc = 32'd200;
    target_address = 32'd300;
    control_transfer = 1'b0;

    #10;

    $display("Test 3: Normal");
    $display("PC = %d | Target = %d | Control = %b | Next PC = %d",
             pc, target_address, control_transfer, next_pc);

    if (next_pc == 32'd204)
        $display("PASS");
    else
        $display("FAIL");


    // Test 4: Jump
    pc = 32'd400;
    target_address = 32'd500;
    control_transfer = 1'b1;

    #10;

    $display("Test 4: Jump");
    $display("PC = %d | Target = %d | Control = %b | Next PC = %d",
             pc, target_address, control_transfer, next_pc);

    if (next_pc == 32'd500)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");
    $finish;

end

endmodule