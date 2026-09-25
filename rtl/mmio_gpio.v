`timescale 1ns/1ps

module mmio_gpio (
    input  wire        clk,
    input  wire        rst,

    input  wire        write_enable,
    input  wire        read_enable,

    input  wire [31:0] write_data,
    output reg  [31:0] read_data,

    output reg  [31:0] gpio_out
);

    always @(posedge clk) begin

        if (rst) begin
            gpio_out <= 32'b0;
        end
        else if (write_enable) begin
            gpio_out <= write_data;
        end

    end

    always @(*) begin

        if (read_enable)
            read_data = gpio_out;
        else
            read_data = 32'b0;

    end

endmodule