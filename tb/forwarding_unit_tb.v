`timescale 1ns/1ps

module forwarding_unit_tb;

reg [4:0] ex_rs1;
reg [4:0] ex_rs2;

reg [4:0] mem_rd;
reg mem_reg_write;

reg [4:0] wb_rd;
reg wb_reg_write;

wire [1:0] forward_a;
wire [1:0] forward_b;

forwarding_unit dut (
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),

    .mem_rd(mem_rd),
    .mem_reg_write(mem_reg_write),

    .wb_rd(wb_rd),
    .wb_reg_write(wb_reg_write),

    .forward_a(forward_a),
    .forward_b(forward_b)
);

initial begin

    $monitor(
        "Time=%0t | EX_RS1=%d | EX_RS2=%d | MEM_RD=%d | MEM_RegWrite=%b | WB_RD=%d | WB_RegWrite=%b | ForwardA=%b | ForwardB=%b",
        $time,
        ex_rs1,
        ex_rs2,
        mem_rd,
        mem_reg_write,
        wb_rd,
        wb_reg_write,
        forward_a,
        forward_b
    );

    // -------------------------------------------------
    // Test 1: No forwarding
    // -------------------------------------------------

    ex_rs1 = 5'd1;
    ex_rs2 = 5'd2;

    mem_rd = 5'd3;
    mem_reg_write = 1'b1;

    wb_rd = 5'd4;
    wb_reg_write = 1'b1;

    #10;


    // -------------------------------------------------
    // Test 2: Forward from EX/MEM to operand A
    // -------------------------------------------------

    ex_rs1 = 5'd3;
    ex_rs2 = 5'd2;

    #10;


    // -------------------------------------------------
    // Test 3: Forward from EX/MEM to operand B
    // -------------------------------------------------

    ex_rs1 = 5'd1;
    ex_rs2 = 5'd3;

    #10;


    // -------------------------------------------------
    // Test 4: Forward from MEM/WB to operand A
    // -------------------------------------------------

    ex_rs1 = 5'd4;
    ex_rs2 = 5'd2;

    mem_rd = 5'd3;

    #10;


    // -------------------------------------------------
    // Test 5: Forward from MEM/WB to operand B
    // -------------------------------------------------

    ex_rs1 = 5'd1;
    ex_rs2 = 5'd4;

    #10;


    // -------------------------------------------------
    // Test 6: Both operands forwarded from EX/MEM
    // -------------------------------------------------

    ex_rs1 = 5'd3;
    ex_rs2 = 5'd3;

    mem_rd = 5'd3;
    mem_reg_write = 1'b1;

    #10;


    // -------------------------------------------------
    // Test 7: x0 should never be forwarded
    // -------------------------------------------------

    ex_rs1 = 5'd0;
    ex_rs2 = 5'd0;

    mem_rd = 5'd0;
    mem_reg_write = 1'b1;

    wb_rd = 5'd0;
    wb_reg_write = 1'b1;

    #10;

    $finish;

end

initial begin
    $dumpfile("forwarding_unit.vcd");
    $dumpvars(0, forwarding_unit_tb);
end

endmodule