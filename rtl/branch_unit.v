module branch_unit (
    input  [31:0] rs1_value,
    input  [31:0] rs2_value,
    input  [31:0] pc,
    input  [31:0] immediate,

    input         branch,
    input         jump,

    input  [2:0]  func3,

    output reg        branch_taken,
    output reg [31:0] target_address
);

always @(*) begin

    branch_taken  = 1'b0;
    target_address = pc + immediate;

    // ---------------------------------------------------------
    // Conditional branches
    // ---------------------------------------------------------

    if (branch) begin

        case (func3)

            // BEQ
            3'b000: begin
                if (rs1_value == rs2_value)
                    branch_taken = 1'b1;
            end

            // BNE
            3'b001: begin
                if (rs1_value != rs2_value)
                    branch_taken = 1'b1;
            end

            // BLT
            3'b100: begin
                if ($signed(rs1_value) < $signed(rs2_value))
                    branch_taken = 1'b1;
            end

            // BGE
            3'b101: begin
                if ($signed(rs1_value) >= $signed(rs2_value))
                    branch_taken = 1'b1;
            end

            // BLTU
            3'b110: begin
                if (rs1_value < rs2_value)
                    branch_taken = 1'b1;
            end

            // BGEU
            3'b111: begin
                if (rs1_value >= rs2_value)
                    branch_taken = 1'b1;
            end

            default: begin
                branch_taken = 1'b0;
            end

        endcase

    end

    // ---------------------------------------------------------
    // Jumps
    // ---------------------------------------------------------

    if (jump) begin
        branch_taken = 1'b1;
        target_address = pc + immediate;
    end

end

endmodule