`timescale 1ns/1ps

module soc_bus (

    // ============================================================
    // CPU DATA BUS
    // ============================================================

    input  wire        cpu_read,
    input  wire        cpu_write,
    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_wdata,

    output wire [31:0] cpu_rdata,


    // ============================================================
    // RAM BUS
    // ============================================================

    output wire        ram_read,
    output wire        ram_write,
    output wire [31:0] ram_addr,
    output wire [31:0] ram_wdata,

    input  wire [31:0] ram_rdata,


    // ============================================================
    // MMIO BUS
    // ============================================================

    output wire        mmio_read,
    output wire        mmio_write,
    output wire [31:0] mmio_addr,
    output wire [31:0] mmio_wdata,

    input  wire [31:0] mmio_rdata,


    // ============================================================
    // CHIP SELECTS
    // ============================================================

    output wire        ram_sel,
    output wire        mmio_sel

);


    // ============================================================
    // ADDRESS MAP
    // ============================================================

    localparam RAM_BASE =
        32'h00000000;

    localparam RAM_LIMIT =
        32'h00000FFF;


    localparam MMIO_BASE =
        32'h10000000;

    localparam MMIO_LIMIT =
        32'h1000001F;


    // ============================================================
    // ADDRESS DECODER
    // ============================================================

    assign ram_sel =
        (cpu_addr >= RAM_BASE) &&
        (cpu_addr <= RAM_LIMIT);


    assign mmio_sel =
        (cpu_addr >= MMIO_BASE) &&
        (cpu_addr <= MMIO_LIMIT);


    // ============================================================
    // RAM BUS
    // ============================================================

    assign ram_read =
        cpu_read &&
        ram_sel;


    assign ram_write =
        cpu_write &&
        ram_sel;


    assign ram_addr =
        cpu_addr;


    assign ram_wdata =
        cpu_wdata;


    // ============================================================
    // MMIO BUS
    // ============================================================

    assign mmio_read =
        cpu_read &&
        mmio_sel;


    assign mmio_write =
        cpu_write &&
        mmio_sel;


    assign mmio_addr =
        cpu_addr;


    assign mmio_wdata =
        cpu_wdata;


    // ============================================================
    // READ DATA MUX
    // ============================================================

    assign cpu_rdata =
        ram_sel
            ? ram_rdata
            :
        mmio_sel
            ? mmio_rdata
            :
            32'h00000000;


endmodule