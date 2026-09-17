`timescale 1ns/1ps

module pipeline_mem_wb_tb;

reg clk;
reg rst;

reg [31:0] alu_result_in;
reg [31:0] memory_data_in;
reg [31:0] link_address_in;

reg [4:0] rd_in;

reg reg_write_in;
reg mem_to_reg_in;
reg jump_in;

wire [31:0] alu_result_out;
wire [31:0] memory_data_out;
wire [31:0] link_address_out;

wire [4:0] rd_out;

wire reg_write_out;
wire mem_to_reg_out;
wire jump_out;

pipeline_mem_wb dut (
    .clk(clk),
    .rst(rst),

    .alu_result_in(alu_result_in),
    .memory_data_in(memory_data_in),
    .link_address_in(link_address_in),

    .rd_in(rd_in),

    .reg_write_in(reg_write_in),
    .mem_to_reg_in(mem_to_reg_in),
    .jump_in(jump_in),

    .alu_result_out(alu_result_out),
    .memory_data_out(memory_data_out),
    .link_address_out(link_address_out),

    .rd_out(rd_out),

    .reg_write_out(reg_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .jump_out(jump_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    $display("======================================");
    $display("       MEM/WB PIPELINE REGISTER");
    $display("======================================");

    rst = 1;

    alu_result_in = 32'd500;
    memory_data_in = 32'd1000;
    link_address_in = 32'd104;

    rd_in = 5'd1;

    reg_write_in = 1'b1;
    mem_to_reg_in = 1'b0;
    jump_in = 1'b1;

    #10;

    rst = 0;

    #10;

    $display("ALU Result = %d", alu_result_out);
    $display("Memory     = %d", memory_data_out);
    $display("Link       = %d", link_address_out);
    $display("RD         = %d", rd_out);
    $display("RegWrite   = %b", reg_write_out);
    $display("Jump       = %b", jump_out);

    if (alu_result_out == 500 &&
        memory_data_out == 1000 &&
        link_address_out == 104 &&
        rd_out == 1 &&
        reg_write_out == 1 &&
        jump_out == 1)
        $display("PASS");
    else
        $display("FAIL");

    $display("======================================");

    $finish;

end

endmodule