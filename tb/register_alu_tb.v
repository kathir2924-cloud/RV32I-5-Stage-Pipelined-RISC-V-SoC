module register_alu_tb;
reg write_enable;
reg clk;
reg [4:0]write_addr;
reg [31:0]write_data;
reg [4:0]read_addr1;
reg [4:0]read_addr2;
wire [31:0]read_data1;
wire [31:0]read_data2;
wire [31:0]alu_result;
reg [3:0]alu_op;

register_file dut1(
    .clk(clk),
    .write_enable(write_enable),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_addr1(read_addr1),
    .read_addr2(read_addr2),
    .read_data1(read_data1),
    .read_data2(read_data2)
);
alu dut2(
    .a(read_data1),
    .b(read_data2),
    .y(alu_result),
    .op(alu_op)

);  
initial begin
    clk=0;
    forever #5 clk=~clk;
end 

initial begin
    write_enable=1;
    write_addr=5'd1;
    write_data=32'd10;
    #10;


    write_enable=1;
    write_addr=5'd2;
    write_data=32'd20;
    #10;


    read_addr1=1;
    read_addr2=2;
    alu_op = 4'b0000;


    $monitor("Time=%0t | x1=%d | x2=%d | ALU op=%d | ALU Result=%d",
         $time, read_data1, read_data2,alu_op, alu_result);

#10;
$finish;
end
endmodule