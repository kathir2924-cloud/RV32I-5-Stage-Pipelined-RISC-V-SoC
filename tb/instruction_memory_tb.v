module instruction_memory_tb;
reg [31:0]address;
wire [31:0]instruction;

instruction_memory dut(
.address(address),
.instruction(instruction)

);
initial begin
    address=32'd4;
    #10;

    address=32'd8;
    #10;

    $finish;
end

initial begin
    $monitor("Time=%0d | Address=%d | Instruction=%h",$time,address,instruction);
end
endmodule