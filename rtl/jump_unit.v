module jump_unit (
    input  [31:0] pc,
    input  [31:0] rs1_value,
    input  [31:0] immediate,
    input         jump,
    input         jalr,

    output reg [31:0] target_address,
    output reg        jump_taken
);

always @(*) begin

    target_address = 32'b0;
    jump_taken = 1'b0;

    if (jump) begin

        jump_taken = 1'b1;

        if (jalr) begin
            // JALR target = (rs1 + immediate) & ~1
            target_address = (rs1_value + immediate) & 32'hFFFFFFFE;
        end
        else begin
            // JAL target = PC + immediate
            target_address = pc + immediate;
        end

    end

end

endmodule