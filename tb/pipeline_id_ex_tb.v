`timescale 1ns/1ps

module pipeline_id_ex_tb;

reg clk;
reg rst;
reg flush;

reg [31:0] pc_in;
reg [31:0] read_data1_in;
reg [31:0] read_data2_in;
reg [31:0] immediate_in;

reg [4:0] rs1_in;
reg [4:0] rs2_in;
reg [4:0] rd_in;

reg [2:0] func3_in;
reg [6:0] func7_in;

reg reg_write_in;
reg mem_read_in;
reg mem_write_in;
reg mem_to_reg_in;
reg alu_src_in;
reg branch_in;
reg jump_in;
reg [1:0] alu_op_in;

wire [31:0] pc_out;
wire [31:0] read_data1_out;
wire [31:0] read_data2_out;
wire [31:0] immediate_out;

wire [4:0] rs1_out;
wire [4:0] rs2_out;
wire [4:0] rd_out;

wire [2:0] func3_out;
wire [6:0] func7_out;

wire reg_write_out;
wire mem_read_out;
wire mem_write_out;
wire mem_to_reg_out;
wire alu_src_out;
wire branch_out;
wire jump_out;
wire [1:0] alu_op_out;

pipeline_id_ex dut (
    .clk(clk),
    .rst(rst),
    .flush(flush),

    .pc_in(pc_in),
    .read_data1_in(read_data1_in),
    .read_data2_in(read_data2_in),
    .immediate_in(immediate_in),

    .rs1_in(rs1_in),
    .rs2_in(rs2_in),
    .rd_in(rd_in),

    .func3_in(func3_in),
    .func7_in(func7_in),

    .reg_write_in(reg_write_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in),
    .alu_src_in(alu_src_in),
    .branch_in(branch_in),
    .jump_in(jump_in),
    .alu_op_in(alu_op_in),

    .pc_out(pc_out),
    .read_data1_out(read_data1_out),
    .read_data2_out(read_data2_out),
    .immediate_out(immediate_out),

    .rs1_out(rs1_out),
    .rs2_out(rs2_out),
    .rd_out(rd_out),

    .func3_out(func3_out),
    .func7_out(func7_out),

    .reg_write_out(reg_write_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .alu_src_out(alu_src_out),
    .branch_out(branch_out),
    .jump_out(jump_out),
    .alu_op_out(alu_op_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    $display("======================================");
    $display("       ID/EX PIPELINE REGISTER");
    $display("======================================");

    rst = 1;
    flush = 0;

    pc_in = 32'd100;
    read_data1_in = 32'd10;
    read_data2_in = 32'd20;
    immediate_in = 32'd50;

    rs1_in = 5'd1;
    rs2_in = 5'd2;
    rd_in = 5'd3;

    func3_in = 3'b000;
    func7_in = 7'b0000000;

    reg_write_in = 1;
    mem_read_in = 0;
    mem_write_in = 0;
    mem_to_reg_in = 0;
    alu_src_in = 0;
    branch_in = 0;
    jump_in = 0;
    alu_op_in = 2'b10;

    #10;

    rst = 0;

    #10;

    $display("Test 1: Normal Capture");
    $display("PC = %d | A = %d | B = %d | Imm = %d | RD = %d",
             pc_out,
             read_data1_out,
             read_data2_out,
             immediate_out,
             rd_out);

    if (pc_out == 100 &&
        read_data1_out == 10 &&
        read_data2_out == 20 &&
        immediate_out == 50 &&
        rd_out == 3 &&
        reg_write_out == 1)
        $display("PASS");
    else
        $display("FAIL");


    // Flush
    flush = 1;

    #10;

    $display("Test 2: Flush");
    $display("PC = %d | A = %d | B = %d | RD = %d | RegWrite = %b",
             pc_out,
             read_data1_out,
             read_data2_out,
             rd_out,
             reg_write_out);

    if (pc_out == 0 &&
        read_data1_out == 0 &&
        read_data2_out == 0 &&
        rd_out == 0 &&
        reg_write_out == 0)
        $display("PASS");
    else
        $display("FAIL");


    // Normal operation after flush
    flush = 0;

    pc_in = 32'd200;
    read_data1_in = 32'd30;
    read_data2_in = 32'd40;
    immediate_in = 32'd60;
    rd_in = 5'd5;

    #10;

    $display("Test 3: Capture After Flush");
    $display("PC = %d | A = %d | B = %d | RD = %d",
             pc_out,
             read_data1_out,
             read_data2_out,
             rd_out);

    if (pc_out == 200 &&
        read_data1_out == 30 &&
        read_data2_out == 40 &&
        immediate_out == 60 &&
        rd_out == 5)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule