`timescale 1ns/1ps

module hazard_detection_unit_tb;

reg        id_ex_mem_read;
reg [4:0]  id_ex_rd;

reg [4:0]  if_id_rs1;
reg [4:0]  if_id_rs2;

wire       stall;

hazard_detection_unit dut (
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rd(id_ex_rd),

    .if_id_rs1(if_id_rs1),
    .if_id_rs2(if_id_rs2),

    .stall(stall)
);

initial begin

    // ------------------------------------------------
    // Test 1: No load
    // ------------------------------------------------

    id_ex_mem_read = 1'b0;
    id_ex_rd       = 5'd5;

    if_id_rs1      = 5'd5;
    if_id_rs2      = 5'd2;

    #10;


    // ------------------------------------------------
    // Test 2: Load-use hazard through rs1
    // ------------------------------------------------

    id_ex_mem_read = 1'b1;
    id_ex_rd       = 5'd5;

    if_id_rs1      = 5'd5;
    if_id_rs2      = 5'd2;

    #10;


    // ------------------------------------------------
    // Test 3: Load-use hazard through rs2
    // ------------------------------------------------

    id_ex_mem_read = 1'b1;
    id_ex_rd       = 5'd5;

    if_id_rs1      = 5'd1;
    if_id_rs2      = 5'd5;

    #10;


    // ------------------------------------------------
    // Test 4: No dependency
    // ------------------------------------------------

    id_ex_mem_read = 1'b1;
    id_ex_rd       = 5'd5;

    if_id_rs1      = 5'd1;
    if_id_rs2      = 5'd2;

    #10;


    // ------------------------------------------------
    // Test 5: Destination is x0
    // ------------------------------------------------

    id_ex_mem_read = 1'b1;
    id_ex_rd       = 5'd0;

    if_id_rs1      = 5'd0;
    if_id_rs2      = 5'd2;

    #10;


    // ------------------------------------------------
    // Test 6: Both rs1 and rs2 depend on load
    // ------------------------------------------------

    id_ex_mem_read = 1'b1;
    id_ex_rd       = 5'd7;

    if_id_rs1      = 5'd7;
    if_id_rs2      = 5'd7;

    #10;

    $finish;

end

initial begin

    $monitor(
        "Time=%0t | ID_EX_MemRead=%b | ID_EX_RD=%d | IF_ID_RS1=%d | IF_ID_RS2=%d | Stall=%b",
        $time,
        id_ex_mem_read,
        id_ex_rd,
        if_id_rs1,
        if_id_rs2,
        stall
    );

end

initial begin

    $dumpfile("hazard_detection_unit.vcd");
    $dumpvars(0, hazard_detection_unit_tb);

end

endmodule