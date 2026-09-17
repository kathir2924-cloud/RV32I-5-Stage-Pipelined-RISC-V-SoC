module mux2_1_32bit_tb;

reg  [31:0] a;
reg  [31:0] b;
reg         sel;

wire [31:0] y;

mux2_1_32bit dut (
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)
);

initial begin

    $monitor("Time=%0t | A=%h | B=%h | Sel=%b | Y=%h",
             $time, a, b, sel, y);

    // Select A
    a = 32'h11111111;
    b = 32'h22222222;
    sel = 1'b0;
    #10;

    // Select B
    sel = 1'b1;
    #10;

    // Another test
    a = 32'h12345678;
    b = 32'hABCDEF00;
    sel = 1'b0;
    #10;

    // Select B
    sel = 1'b1;
    #10;

    $finish;
end

endmodule