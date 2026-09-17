module mux2_1_4bit(
    input [3:0]a,
    input [3:0]b,
    input sel,
    output [3:0]y
);
assign y=(sel==0) ? a : b;
endmodule