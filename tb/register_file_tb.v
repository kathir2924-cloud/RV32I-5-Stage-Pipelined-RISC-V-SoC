
module register_file_tb;

    reg clk;
    reg write_enable;
    reg [4:0] write_addr;
    reg [31:0] write_data;
    reg [4:0] read_addr1;
    reg [4:0] read_addr2;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    register_file dut (
        .clk(clk),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
initial begin
    clk=0;
    forever #5 clk=~clk;
end
initial begin
    read_addr1=0;
    read_addr2=0;
    write_enable=1;
    write_addr=5;
    write_data=32'd100;
    #10;
    write_enable=0;

    read_addr1=5;

    write_enable=1;
    write_addr=2;
    write_data=32'd200;
    #10;

    write_enable=0;
    read_addr2=2;
#5;
$finish;
end


initial begin
    $monitor("Time=%0t | clk=%b | WE=%b | WADDR=%d | WDATA=%d | RADDR1=%d | RDATA1=%d | RADDR2=%d | RDATA2=%d  ",
         $time, clk, write_enable, write_addr, write_data, read_addr1, read_data1,read_addr2,read_data2);
end
endmodule