`timescale 1ns/1ps

module jump_link_unit_tb;

reg  [31:0] pc;
reg         jump;

wire [31:0] link_address;

jump_link_unit dut (
    .pc(pc),
    .jump(jump),
    .link_address(link_address)
);

initial begin

    $display("======================================");
    $display("        JUMP LINK UNIT TEST");
    $display("======================================");

    // Test 1: No jump
    pc = 32'd100;
    jump = 1'b0;

    #10;

    $display("Test 1: No Jump");
    $display("PC = %d | Jump = %b | Link = %d",
             pc, jump, link_address);

    if (link_address == 32'd0)
        $display("PASS");
    else
        $display("FAIL");


    // Test 2: JAL
    pc = 32'd100;
    jump = 1'b1;

    #10;

    $display("Test 2: JAL");
    $display("PC = %d | Jump = %b | Link = %d",
             pc, jump, link_address);

    if (link_address == 32'd104)
        $display("PASS");
    else
        $display("FAIL");


    // Test 3: Another PC
    pc = 32'd200;
    jump = 1'b1;

    #10;

    $display("Test 3: JAL/JALR");
    $display("PC = %d | Jump = %b | Link = %d",
             pc, jump, link_address);

    if (link_address == 32'd204)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule