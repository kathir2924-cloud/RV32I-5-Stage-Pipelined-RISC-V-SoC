module alu(
    input [31:0]a,
    input [31:0]b,
    input [3:0]op,
    output reg[31:0]y
);
always @(*) begin
    

case (op)
 4'b0000 : y=a+b;
 4'b0001 : y=a-b;
 4'b0010 : y=a&b;
 4'b0011 : y=a|b;
 4'b0100 : y=a^b;
 4'b0101 : y=a<<b;
 4'b0110 : y=a>>b;
 4'b0111 : y=$signed(a)>>>b;
 4'b1000 : y= $signed(a)<$signed(b) ;
 4'b1001 : y=a<b;
 default: y=4'b0000;
endcase
end
endmodule