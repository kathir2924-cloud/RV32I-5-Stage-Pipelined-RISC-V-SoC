`timescale 1ns/1ps

module forwarding_mux_tb;

reg [31:0] original_value;
reg [31:0] mem_value;
reg [31:0] wb_value;
reg [1:0] select;

wire [31:0] result;

forwarding_mux dut (
    .original_value(original_value),
    .mem_value(mem_value),
    .wb_value(wb_value),
    .select(select),
    .result(result)
);

initial begin

    original_value = 32'd100;
    mem_value      = 32'd200;
    wb_value       = 32'd300;

    // Normal value
    select = 2'b00;
    #10;

    // Forward from EX/MEM
    select = 2'b10;
    #10;

    // Forward from MEM/WB
    select = 2'b01;
    #10;

    // Invalid selection
    select = 2'b11;
    #10;

    $finish;
end

initial begin
    $monitor(
        "Time=%0t | Original=%d | MEM=%d | WB=%d | Select=%b | Result=%d",
        $time,
        original_value,
        mem_value,
        wb_value,
        select,
        result
    );
end

initial begin
    $dumpfile("forwarding_mux.vcd");
    $dumpvars(0, forwarding_mux_tb);
end

endmodule