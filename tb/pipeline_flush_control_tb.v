`timescale 1ns/1ps

module pipeline_flush_control_tb;

reg control_transfer;

wire flush_if_id;
wire flush_id_ex;

pipeline_flush_control dut (
    .control_transfer(control_transfer),
    .flush_if_id(flush_if_id),
    .flush_id_ex(flush_id_ex)
);

initial begin

    $display("======================================");
    $display("   PIPELINE FLUSH CONTROL TEST");
    $display("======================================");

    // Test 1: Normal instruction
    control_transfer = 1'b0;

    #10;

    $display("Test 1: No Branch/Jump");
    $display("Control Transfer = %b | Flush IF/ID = %b | Flush ID/EX = %b",
             control_transfer, flush_if_id, flush_id_ex);

    if (flush_if_id == 1'b0 && flush_id_ex == 1'b0)
        $display("PASS");
    else
        $display("FAIL");


    // Test 2: Branch taken
    control_transfer = 1'b1;

    #10;

    $display("Test 2: Branch/Jump Taken");
    $display("Control Transfer = %b | Flush IF/ID = %b | Flush ID/EX = %b",
             control_transfer, flush_if_id, flush_id_ex);

    if (flush_if_id == 1'b1 && flush_id_ex == 1'b1)
        $display("PASS");
    else
        $display("FAIL");


    // Test 3: Return to normal
    control_transfer = 1'b0;

    #10;

    $display("Test 3: Normal Instruction");
    $display("Control Transfer = %b | Flush IF/ID = %b | Flush ID/EX = %b",
             control_transfer, flush_if_id, flush_id_ex);

    if (flush_if_id == 1'b0 && flush_id_ex == 1'b0)
        $display("PASS");
    else
        $display("FAIL");


    $display("======================================");

    $finish;

end

endmodule