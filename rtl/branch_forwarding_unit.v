module branch_forwarding_unit (
    input  [4:0] branch_rs1,
    input  [4:0] branch_rs2,

    input  [31:0] original_rs1_value,
    input  [31:0] original_rs2_value,

    input  [4:0] mem_rd,
    input        mem_reg_write,
    input  [31:0] mem_value,

    input  [4:0] wb_rd,
    input        wb_reg_write,
    input  [31:0] wb_value,

    output reg [31:0] branch_rs1_forwarded,
    output reg [31:0] branch_rs2_forwarded
);

always @(*) begin

    // Default: use register-file values
    branch_rs1_forwarded = original_rs1_value;
    branch_rs2_forwarded = original_rs2_value;


    // ------------------------------------------------------------
    // Forward RS1
    // ------------------------------------------------------------

    if (mem_reg_write &&
        (mem_rd != 5'b0) &&
        (mem_rd == branch_rs1)) begin

        branch_rs1_forwarded = mem_value;

    end

    else if (wb_reg_write &&
             (wb_rd != 5'b0) &&
             (wb_rd == branch_rs1)) begin

        branch_rs1_forwarded = wb_value;

    end


    // ------------------------------------------------------------
    // Forward RS2
    // ------------------------------------------------------------

    if (mem_reg_write &&
        (mem_rd != 5'b0) &&
        (mem_rd == branch_rs2)) begin

        branch_rs2_forwarded = mem_value;

    end

    else if (wb_reg_write &&
             (wb_rd != 5'b0) &&
             (wb_rd == branch_rs2)) begin

        branch_rs2_forwarded = wb_value;

    end

end

endmodule