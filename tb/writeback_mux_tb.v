`timescale 1ns/1ps

module writeback_mux_tb;

reg [31:0] alu_result;
reg [31:0] memory_data;
reg [31:0] link_address;

reg mem_to_reg;
reg jump;

wire [31:0] writeback_data;

writeback_mux dut (
    .alu_result(alu_result),
    .memory_data(memory_data),
    .link_address(link_address),
    .mem_to_reg(mem_to_reg),
    .jump(jump),
    .writeback_data(writeback_data)
);

initial begin

    $display("======================================");
    $display("         WRITEBACK MUX TEST");
    $display("======================================");


    // --------------------------------------
    // Test 1: ALU result
    // --------------------------------------

    alu_result = 32'd100;
    memory_data = 32'd200;
    link_address = 32'd104;

    mem_to_reg = 1'b0;
    jump = 1'b0;

    #10;

    $display("Test 1: ALU");
    $display("ALU = %d | MEM = %d | LINK = %d | WB = %d",
             alu_result,
             memory_data,
             link_address,
             writeback_data);

    if (writeback_data == 32'd100)
        $display("PASS");
    else
        $display("FAIL");


    // --------------------------------------
    // Test 2: Memory data
    // --------------------------------------

    mem_to_reg = 1'b1;
    jump = 1'b0;

    #10;

    $display("Test 2: LOAD");
    $display("ALU = %d | MEM = %d | LINK = %d | WB = %d",
             alu_result,
             memory_data,
             link_address,
             writeback_data);

    if (writeback_data == 32'd200)
        $display("PASS");
    else
        $display("FAIL");


    // --------------------------------------
    // Test 3: JAL
    // --------------------------------------

    mem_to_reg = 1'b0;
    jump = 1'b1;

    #10;

    $display("Test 3: JAL/JALR");
    $display("ALU = %d | MEM = %d | LINK = %d | WB = %d",
             alu_result,
             memory_data,
             link_address,
             writeback_data);

    if (writeback_data == 32'd104)
        $display("PASS");
    else
        $display("FAIL");


    // --------------------------------------
    // Test 4: Jump has priority
    // --------------------------------------

    mem_to_reg = 1'b1;
    jump = 1'b1;

    #10;

    $display("Test 4: Jump Priority");
    $display("ALU = %d | MEM = %d | LINK = %d | WB = %d",
             alu_result,
             memory_data,
             link_address,
             writeback_data);

    if (writeback_data == 32'd104)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule