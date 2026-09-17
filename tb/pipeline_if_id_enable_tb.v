`timescale 1ns/1ps

module pipeline_if_id_enable_tb;

reg clk;
reg rst;
reg enable;

reg [31:0] pc_in;
reg [31:0] instruction_in;

wire [31:0] pc_out;
wire [31:0] instruction_out;

pipeline_if_id_enable dut (
    .clk(clk),
    .rst(rst),
    .enable(enable),

    .pc_in(pc_in),
    .instruction_in(instruction_in),

    .pc_out(pc_out),
    .instruction_out(instruction_out)
);

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    rst = 1;
    enable = 0;

    pc_in = 0;
    instruction_in = 0;

    #10;

    rst = 0;
    enable = 1;

    pc_in = 32'h00000004;
    instruction_in = 32'h11111111;

    #10;

    pc_in = 32'h00000008;
    instruction_in = 32'h22222222;

    #10;

    // Freeze IF/ID
    enable = 0;

    pc_in = 32'h0000000C;
    instruction_in = 32'h33333333;

    #10;

    // Continue
    enable = 1;

    pc_in = 32'h00000010;
    instruction_in = 32'h44444444;

    #10;

    $finish;
end

initial begin
    $monitor(
        "Time=%0t | Reset=%b | Enable=%b | PC_in=%h | PC_out=%h | Instruction_in=%h | Instruction_out=%h",
        $time,
        rst,
        enable,
        pc_in,
        pc_out,
        instruction_in,
        instruction_out
    );
end

initial begin
    $dumpfile("pipeline_if_id_enable.vcd");
    $dumpvars(0, pipeline_if_id_enable_tb);
end

endmodule