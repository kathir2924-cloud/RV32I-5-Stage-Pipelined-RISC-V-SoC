module program_counter_tb;
reg clk;
reg rst;
wire [31:0]pc;

program_counter dut(
    .clk(clk),
    .rst(rst),
    .pc(pc)

);

initial begin
    clk=0;
    forever #5 clk=~clk;
end

initial begin
    rst=1;
    #10;

    rst=0;
    #10;

    $finish;
    #10;
end

initial begin
    $monitor("Time=%0t | clk=%b | rst=%b | PC=%d",
             $time, clk, rst, pc);
end

endmodule