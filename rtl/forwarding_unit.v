    module forwarding_unit (
    input  [4:0] ex_rs1,
    input  [4:0] ex_rs2,

    input  [4:0] mem_rd,
    input        mem_reg_write,

    input  [4:0] wb_rd,
    input        wb_reg_write,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

always @(*) begin

    // Default: use values from ID/EX register
    forward_a = 2'b00;
    forward_b = 2'b00;

    // EX hazard
    if (mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs1))
        forward_a = 2'b10;

    if (mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs2))
        forward_b = 2'b10;

    // MEM hazard
    if (wb_reg_write && (wb_rd != 0) &&
        !(mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs1)) &&
        (wb_rd == ex_rs1))
        forward_a = 2'b01;

    if (wb_reg_write && (wb_rd != 0) &&
        !(mem_reg_write && (mem_rd != 0) && (mem_rd == ex_rs2)) &&
        (wb_rd == ex_rs2))
        forward_b = 2'b01;

end

endmodule