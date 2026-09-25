`timescale 1ns/1ps

module soc_ram #(
    parameter ADDR_WIDTH = 12
)(
    input  wire        clk,

    // Read interface
    input  wire        read_en,
    input  wire [31:0] read_addr,
    output reg  [31:0] read_data,

    // Write interface
    input  wire        write_en,
    input  wire [31:0] write_addr,
    input  wire [31:0] write_data
);

    // ============================================================
    // MEMORY PARAMETERS
    // ============================================================

    localparam DEPTH = (1 << (ADDR_WIDTH - 2));

    // 32-bit word-addressable RAM
    // ADDR_WIDTH = 12 -> 4096 bytes -> 1024 words
    reg [31:0] mem [0:DEPTH-1];

    integer i;

    // ============================================================
    // INITIALIZE RAM
    // ============================================================

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'h00000000;
    end

    // ============================================================
    // COMBINATIONAL READ
    // ============================================================

    always @(*) begin

        if (read_en)
            read_data = mem[read_addr[ADDR_WIDTH-1:2]];
        else
            read_data = 32'h00000000;

    end

    // ============================================================
    // SYNCHRONOUS WRITE
    // ============================================================

    always @(posedge clk) begin

        if (write_en)
            mem[write_addr[ADDR_WIDTH-1:2]] <= write_data;

    end

endmodule