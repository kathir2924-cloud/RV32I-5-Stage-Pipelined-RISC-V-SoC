`timescale 1ns/1ps

module single_cycle_core_tb;

reg clk;
reg rst;

single_cycle_core dut (
    .clk(clk),
    .rst(rst)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Reset and simulation
initial begin

    rst = 1;

    #10;
    rst = 0;

    #50;

    $finish;
end

// Monitor important internal signals
initial begin
    $monitor(
        "Time=%0t | Reset=%b | PC=%h | Instruction=%h | Opcode=%b | ALUResult=%h",
        $time,
        rst,
        dut.pc,
        dut.instruction,
        dut.opcode,
        dut.alu_result
    );
end

// Generate waveform
initial begin
    $dumpfile("single_cycle_core.vcd");
    $dumpvars(0, single_cycle_core_tb);
end

endmodule