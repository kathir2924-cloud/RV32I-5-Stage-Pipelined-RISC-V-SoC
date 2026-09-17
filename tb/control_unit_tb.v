`timescale 1ns/1ps

module control_unit_tb;

reg [6:0] opcode;

wire reg_write;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire alu_src;
wire branch;
wire jump;
wire jalr;
wire [1:0] alu_op;

control_unit dut (
    .opcode(opcode),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .jump(jump),
    .jalr(jalr),
    .alu_op(alu_op)
);

initial begin

    $display("======================================");
    $display("        CONTROL UNIT TEST");
    $display("======================================");

    // JAL
    opcode = 7'b1101111;

    #10;

    $display("JAL:");
    $display("RegWrite=%b Jump=%b JALR=%b",
             reg_write, jump, jalr);

    if (reg_write && jump && !jalr)
        $display("PASS");
    else
        $display("FAIL");


    // JALR
    opcode = 7'b1100111;

    #10;

    $display("JALR:");
    $display("RegWrite=%b Jump=%b JALR=%b",
             reg_write, jump, jalr);

    if (reg_write && jump && jalr)
        $display("PASS");
    else
        $display("FAIL");


    // R-type
    opcode = 7'b0110011;

    #10;

    $display("R-type:");
    $display("RegWrite=%b Jump=%b JALR=%b ALUOp=%b",
             reg_write, jump, jalr, alu_op);

    if (reg_write && !jump && alu_op == 2'b10)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule