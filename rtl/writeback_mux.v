module writeback_mux (
    input  [31:0] alu_result,
    input  [31:0] memory_data,
    input  [31:0] link_address,

    input         mem_to_reg,
    input         jump,

    output reg [31:0] writeback_data
);

always @(*) begin

    if (jump) begin
        // JAL / JALR
        writeback_data = link_address;
    end
    else if (mem_to_reg) begin
        // Load instruction
        writeback_data = memory_data;
    end
    else begin
        // ALU instruction
        writeback_data = alu_result;
    end

end

endmodule