module d_flipflop_tb;
    reg d;
    reg clk;
    wire q;
    
    d_flipflop dut(
        .d(d),
        .clk(clk),
        .q(q)
    );
    
    initial begin
        clk=0;
        forever #5 clk=~clk;
    end
    initial begin 
        d=0;
        #7 d=1;
        #10 d=0;
        #12 d=1;
        #15 d=1;
        #20 d=0;
        $finish;
    end
    initial begin
        $dumpfile("d_flipflop.vcd");
        $dumpvars(0,d_flipflop_tb);
        $monitor("Time =%t  |  clk=%b  |  d=%b  |  q=%b",$time,clk,d,q);
    
    end
endmodule