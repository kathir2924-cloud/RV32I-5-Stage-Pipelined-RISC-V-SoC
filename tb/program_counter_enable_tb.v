`timescale 1ns/1ps

module program_counter_enable_tb;

reg clk;
reg rst;
reg enable;
reg [31:0] next_pc;

wire [31:0] pc;

program_counter_enable dut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .next_pc(next_pc),
    .pc(pc)
);

always #5 clk = ~clk;

initial begin

    $display("======================================");
    $display(" PROGRAM COUNTER NEXT-PC VERIFICATION");
    $display("======================================");

    clk = 0;
    rst = 1;
    enable = 0;
    next_pc = 32'd0;

    #12;

    if (pc == 32'd0)
        $display("RESET PASS");
    else
        $display("RESET FAIL");


    // Normal PC update
    rst = 0;
    enable = 1;
    next_pc = 32'd4;

    #10;

    if (pc == 32'd4)
        $display("PC = 4 PASS");
    else
        $display("PC = 4 FAIL");


    // Normal next instruction
    next_pc = 32'd8;

    #10;

    if (pc == 32'd8)
        $display("PC = 8 PASS");
    else
        $display("PC = 8 FAIL");


    // Branch / jump target
    next_pc = 32'd20;

    #10;

    if (pc == 32'd20)
        $display("CONTROL TRANSFER PASS");
    else
        $display("CONTROL TRANSFER FAIL");


    // Hold PC
    enable = 0;
    next_pc = 32'd100;

    #10;

    if (pc == 32'd20)
        $display("PC HOLD PASS");
    else
        $display("PC HOLD FAIL");


    $display("======================================");

    $finish;

end

endmodule