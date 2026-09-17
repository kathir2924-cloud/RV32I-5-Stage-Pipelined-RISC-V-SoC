`timescale 1ns/1ps

module pipeline_ex_mem_tb;

reg clk;
reg rst;

reg [31:0] alu_result_in;
reg [31:0] read_data2_in;
reg [31:0] link_address_in;

reg [4:0] rd_in;

reg reg_write_in;
reg mem_read_in;
reg mem_write_in;
reg mem_to_reg_in;
reg jump_in;

wire [31:0] alu_result_out;
wire [31:0] read_data2_out;
wire [31:0] link_address_out;

wire [4:0] rd_out;

wire reg_write_out;
wire mem_read_out;
wire mem_write_out;
wire mem_to_reg_out;
wire jump_out;

pipeline_ex_mem dut (
    .clk(clk),
    .rst(rst),

    .alu_result_in(alu_result_in),
    .read_data2_in(read_data2_in),
    .link_address_in(link_address_in),

    .rd_in(rd_in),

    .reg_write_in(reg_write_in),
    .mem_read_in(mem_read_in),
    .mem_write_in(mem_write_in),
    .mem_to_reg_in(mem_to_reg_in),
    .jump_in(jump_in),

    .alu_result_out(alu_result_out),
    .read_data2_out(read_data2_out),
    .link_address_out(link_address_out),

    .rd_out(rd_out),

    .reg_write_out(reg_write_out),
    .mem_read_out(mem_read_out),
    .mem_write_out(mem_write_out),
    .mem_to_reg_out(mem_to_reg_out),
    .jump_out(jump_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    $display("======================================");
    $display("       EX/MEM PIPELINE REGISTER");
    $display("======================================");

    rst = 1;

    alu_result_in = 32'd100;
    read_data2_in = 32'd200;
    link_address_in = 32'd104;

    rd_in = 5'd5;

    reg_write_in = 1'b1;
    mem_read_in = 1'b0;
    mem_write_in = 1'b0;
    mem_to_reg_in = 1'b0;
    jump_in = 1'b1;

    #10;

    rst = 0;

    #10;

    $display("ALU Result  = %d", alu_result_out);
    $display("Read Data 2 = %d", read_data2_out);
    $display("Link        = %d", link_address_out);
    $display("RD          = %d", rd_out);
    $display("RegWrite    = %b", reg_write_out);
    $display("Jump        = %b", jump_out);

    if (alu_result_out == 100 &&
        read_data2_out == 200 &&
        link_address_out == 104 &&
        rd_out == 5 &&
        reg_write_out == 1 &&
        jump_out == 1)
        $display("PASS");
    else
        $display("FAIL");

    $display("======================================");

    $finish;

end

endmodule