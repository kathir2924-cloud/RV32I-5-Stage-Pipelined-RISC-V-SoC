module pc_instruction_memory_tb;

reg clk;
reg rst;

wire [31:0] pc;
wire [31:0] instruction;


// Program Counter
program_counter dut1(
    .clk(clk),
    .rst(rst),
    .pc(pc)
);


// Instruction Memory
instruction_memory dut2(
    .address(pc),
    .instruction(instruction)
);


// Clock generation
initial begin

    clk = 0;

    forever #5 clk = ~clk;

end


// Test
initial begin

    rst = 1;

    #10;

    rst = 0;

    #40;

    $finish;

end


// Display
initial begin

    $monitor("Time=%0t | Reset=%b | PC=%d | Instruction=%h",
             $time, rst, pc, instruction);

end

endmodule