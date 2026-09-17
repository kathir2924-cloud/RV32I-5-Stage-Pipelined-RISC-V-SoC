module alu_control (
    input  [1:0] alu_op,
    input  [2:0] func3,
    input  [6:0] func7,
    output reg [3:0] alu_control
);

always @(*) begin

    // Default: ADD
    alu_control = 4'b0000;

    case (alu_op)

        // Load / Store / AUIPC / JALR
        2'b00: begin
            alu_control = 4'b0000;   // ADD
        end

        // Branch
        2'b01: begin
            alu_control = 4'b0001;   // SUB
        end

        // R-type instructions
        2'b10: begin
            case (func3)

                3'b000: begin
                    if (func7 == 7'b0100000)
                        alu_control = 4'b0001; // SUB
                    else
                        alu_control = 4'b0000; // ADD
                end

                3'b111: alu_control = 4'b0010; // AND
                3'b110: alu_control = 4'b0011; // OR
                3'b100: alu_control = 4'b0100; // XOR
                3'b001: alu_control = 4'b0101; // SLL
                3'b101: begin
                    if (func7 == 7'b0100000)
                        alu_control = 4'b0111; // SRA
                    else
                        alu_control = 4'b0110; // SRL
                end
                3'b010: alu_control = 4'b1000; // SLT
                3'b011: alu_control = 4'b1001; // SLTU

                default: alu_control = 4'b0000;

            endcase
        end

        // I-type ALU instructions
        2'b11: begin
            case (func3)

                3'b000: alu_control = 4'b0000; // ADDI
                3'b111: alu_control = 4'b0010; // ANDI
                3'b110: alu_control = 4'b0011; // ORI
                3'b100: alu_control = 4'b0100; // XORI
                3'b001: alu_control = 4'b0101; // SLLI
                3'b101: begin
                    if (func7 == 7'b0100000)
                        alu_control = 4'b0111; // SRAI
                    else
                        alu_control = 4'b0110; // SRLI
                end
                3'b010: alu_control = 4'b1000; // SLTI
                3'b011: alu_control = 4'b1001; // SLTIU

                default: alu_control = 4'b0000;

            endcase
        end

        default: begin
            alu_control = 4'b0000;
        end

    endcase
end

endmodule