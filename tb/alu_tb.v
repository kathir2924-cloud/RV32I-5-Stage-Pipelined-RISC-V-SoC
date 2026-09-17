module alu_tb;
reg [31:0]a;
reg [31:0]b;
reg [3:0]op;
wire [31:0]y;
reg[31:0]operation;
alu dut(
    .a(a),
    .b(b),
    .op(op),
    .y(y)
);

initial begin
    a=4'b0001;
    b=4'b0011;
    op=4'b0000;
    #10

    a=4'b1010;
    b=4'b0011;
    op=4'b0001;
    #10;


    a=4'b1010;
    b=4'b0011;
    op=4'b0010;
    #10;


    a=4'b1010;
    b=4'b0011;
    op=4'b0011;
    #10;


    a=4'b1111;
    b=4'b0000;
    op=4'b0100;
    #10;


    a = 4'b0011;
b = 4'b0001;
op = 4'b0101;
#10;


   a = 4'b0011;
b = 4'b0001;
op = 4'b0110;
#10;


  a = 32'b11111111111111111111111111111100;
b = 32'd1;
op = 4'b0111;
#10;

   a = 4'b1101;
b = 4'b0010;
op = 4'b1000;
#10;



  a = 4'b1101;
b = 4'b0010;
op = 4'b1001;
#10;

a = 32'd10;
b = 32'd20;
op = 4'b0000;
#10;

$finish;
end
always @(*) begin
      case(op)
     4'b0000: operation = "ADD";
    4'b0001: operation = "SUB";
    4'b0010: operation = "AND";
    4'b0011: operation = "OR";
    4'b0100: operation = "XOR";
    4'b0101: operation = "SLL";
    4'b0110: operation = "SRL";
    4'b0111: operation = "SRA";
    4'b1000: operation = "SLT";
    4'b1001: operation = "SLTU";
    default: operation = "UNKNOWN";
endcase
end
initial begin
    
    $dumpfile("alu.vcd");
    $dumpvars(0,alu_tb);
  
    $monitor("Time=%0t  |  A=%4b  |  B=%4b  |  Operation=%s |  Output=%4b",$time,a,b,operation,y);
end
endmodule

