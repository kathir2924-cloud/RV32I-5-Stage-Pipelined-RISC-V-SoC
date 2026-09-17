module data_memory_tb;

reg clk;
reg mem_read;
reg mem_write;
reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

data_memory dut (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)
);

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    // Initial values
    mem_read = 0;
    mem_write = 0;
    address = 0;
    write_data = 0;

    // Write 100 to address 0
    #10;
    address = 32'd0;
    write_data = 32'd100;
    mem_write = 1;

    #10;
    mem_write = 0;

    // Read from address 0
    #10;
    mem_read = 1;

    #10;

    // Write 200 to address 4
    mem_read = 0;
    address = 32'd4;
    write_data = 32'd200;
    mem_write = 1;

    #10;
    mem_write = 0;

    // Read from address 4
    #10;
    mem_read = 1;

    #10;

    $finish;
end

initial begin
    $monitor("Time=%0t | Read=%b | Write=%b | Address=%d | Write_Data=%d | Read_Data=%d",
             $time, mem_read, mem_write, address, write_data, read_data);
end

endmodule