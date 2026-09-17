module mux2_1_4bit_tb;
reg [3:0]a;
reg[3:0]b;
reg sel;
wire [3:0]y;

mux2_1_4bit dut(
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)
);
initial begin 
    sel = 0;
    a=4'b0111;
    b=4'b1010;
    #10
     

    sel=1;
    a=4'b0001;
    b=4'b1111;
    #10
    

    sel=1;
    a=4'b1101;
    b=4'b0011;
    $finish;
end
initial begin
    $dumpfile("mux2_1_4bit.vcd");
    $dumpvars(0,mux2_1_4bit_tb);
    $monitor("Time=%0t  |  A=%4b  |  B=%4b  |  Select line=%b  |  Output=%4b",$time,a,b,sel,y);
end
endmodule