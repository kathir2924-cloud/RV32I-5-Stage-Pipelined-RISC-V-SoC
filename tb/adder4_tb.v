module adder4_tb;
reg [3:0]a;
reg [3:0]b;
wire [3:0]sum;
wire carry;

adder4 dut(
    .a(a),
    .b(b),
    .sum(sum),
    .carry(carry)
);
initial begin
a = 4'b0101;
b = 4'b0011;
#10;

a = 4'b1111;
b = 4'b0001;
#10;

a = 4'b0111;
b = 4'b1000;
#10;

a = 4'b1010;
b = 4'b0101;
#10;

$finish;
end
initial begin
    $dumpfile("adder4.vcd");
    $dumpvars(0,adder4_tb);
    $monitor("Time=%0t  |   A=%4b  |  B=%4b  |  Sum=%4b  |  Carry=%4b",$time,a,b,sum,carry);
end
endmodule