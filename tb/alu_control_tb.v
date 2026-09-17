`timescale 1ns/1ps

module alu_control_tb;

reg [1:0] alu_op;
reg [2:0] func3;
reg [6:0] func7;

wire [3:0] alu_control;

alu_control dut (
    .alu_op(alu_op),
    .func3(func3),
    .func7(func7),
    .alu_control(alu_control)
);

initial begin

    // =========================================================
    // ADD
    // =========================================================

    alu_op = 2'b10;
    func3 = 3'b000;
    func7 = 7'b0000000;

    #10;

    if (alu_control == 4'b0000)
        $display("ADD CONTROL PASS");
    else
        $display("ADD CONTROL FAIL: %b", alu_control);


    // =========================================================
    // SUB
    // =========================================================

    alu_op = 2'b10;
    func3 = 3'b000;
    func7 = 7'b0100000;

    #10;

    if (alu_control == 4'b0001)
        $display("SUB CONTROL PASS");
    else
        $display("SUB CONTROL FAIL: %b", alu_control);


    // =========================================================
    // AND
    // =========================================================

    alu_op = 2'b10;
    func3 = 3'b111;
    func7 = 7'b0000000;

    #10;

    if (alu_control == 4'b0010)
        $display("AND CONTROL PASS");
    else
        $display("AND CONTROL FAIL: %b", alu_control);


    // =========================================================
    // OR
    // =========================================================

    alu_op = 2'b10;
    func3 = 3'b110;
    func7 = 7'b0000000;

    #10;

    if (alu_control == 4'b0011)
        $display("OR CONTROL PASS");
    else
        $display("OR CONTROL FAIL: %b", alu_control);


    // =========================================================
    // XOR
    // =========================================================

    alu_op = 2'b10;
    func3 = 3'b100;
    func7 = 7'b0000000;

    #10;

    if (alu_control == 4'b0100)
        $display("XOR CONTROL PASS");
    else
        $display("XOR CONTROL FAIL: %b", alu_control);


    $finish;

end

endmodule