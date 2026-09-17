`timescale 1ns/1ps

module pipeline_if_id_tb;

reg clk;
reg rst;
reg enable;
reg flush;

reg [31:0] pc_in;
reg [31:0] instruction_in;

wire [31:0] pc_out;
wire [31:0] instruction_out;

pipeline_if_id dut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .flush(flush),
    .pc_in(pc_in),
    .instruction_in(instruction_in),
    .pc_out(pc_out),
    .instruction_out(instruction_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    $display("======================================");
    $display("       IF/ID PIPELINE REGISTER");
    $display("======================================");

    rst = 1;
    enable = 1;
    flush = 0;
    pc_in = 32'd100;
    instruction_in = 32'h12345678;

    #10;

    rst = 0;

    #10;

    $display("Test 1: Normal Capture");
    $display("PC = %d | Instruction = %h",
             pc_out, instruction_out);

    if (pc_out == 32'd100 &&
        instruction_out == 32'h12345678)
        $display("PASS");
    else
        $display("FAIL");


    // Flush
    flush = 1;
    pc_in = 32'd200;
    instruction_in = 32'hAAAAAAAA;

    #10;

    $display("Test 2: Flush");
    $display("PC = %d | Instruction = %h",
             pc_out, instruction_out);

    if (pc_out == 32'b0 &&
        instruction_out == 32'b0)
        $display("PASS");
    else
        $display("FAIL");


    // Normal operation after flush
    flush = 0;
    pc_in = 32'd300;
    instruction_in = 32'hBBBBBBBB;

    #10;

    $display("Test 3: Capture After Flush");
    $display("PC = %d | Instruction = %h",
             pc_out, instruction_out);

    if (pc_out == 32'd300 &&
        instruction_out == 32'hBBBBBBBB)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule