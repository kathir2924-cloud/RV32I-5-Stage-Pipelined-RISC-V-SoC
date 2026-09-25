`timescale 1ns/1ps

module mmio_gpio_tb;

    reg clk;
    reg rst;

    reg        write_enable;
    reg        read_enable;
    reg [31:0] write_data;

    wire [31:0] read_data;
    wire [31:0] gpio_out;

    always #5 clk = ~clk;

    mmio_gpio dut (
        .clk(clk),
        .rst(rst),

        .write_enable(write_enable),
        .read_enable(read_enable),

        .write_data(write_data),
        .read_data(read_data),

        .gpio_out(gpio_out)
    );

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        write_enable = 1'b0;
        read_enable  = 1'b0;
        write_data   = 32'b0;

        #20;

        rst = 1'b0;

        // ========================================================
        // WRITE GPIO
        // ========================================================

        @(negedge clk);

        write_enable = 1'b1;
        write_data   = 32'hA5A5_1234;

        @(posedge clk);

        #1;

        if (gpio_out == 32'hA5A5_1234)
            $display("PASS: GPIO WRITE");
        else
            $display(
                "FAIL: GPIO WRITE = %08h",
                gpio_out
            );

        // ========================================================
        // READ GPIO
        // ========================================================

        @(negedge clk);

        write_enable = 1'b0;
        read_enable  = 1'b1;

        #1;

        if (read_data == 32'hA5A5_1234)
            $display("PASS: GPIO READ");
        else
            $display(
                "FAIL: GPIO READ = %08h",
                read_data
            );

        // ========================================================
        // FINAL
        // ========================================================

        $display("");
        $display("==============================================");
        $display(" MMIO GPIO TEST COMPLETE");
        $display("==============================================");

        $finish;

    end

endmodule