module register4_tb;
reg [3:0]d;
reg clk;
wire [3:0]q;

register4 dut(
    .d(d),
    .clk(clk),
    .q(q)
);
initial begin
    clk=0;
    forever #5 clk =~clk;
end
initial begin
    d=4'b0000;
    #7 d=4'b1001;
    #10 d=4'b1101;
    #15 d=4'b1110;
    #20 d=4'b1111;
    $finish;
end
initial begin
    $dumpfile("register4.vcd");
    $dumpvars(0,register4_tb);
    $monitor("Time=%0t  |  clk=%b  |  d=%4b  |  q=%4b",$time,clk,d,q);
end
endmodule 
