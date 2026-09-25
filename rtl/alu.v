module alu(

    input [31:0] a,
    input [31:0] b,
    input [3:0]  op,
    output reg [31:0] y

);

always @(*) begin

    case (op)

        // ADD
        4'b0000:
            y = a + b;

        // SUB
        4'b0001:
            y = a - b;

        // AND
        4'b0010:
            y = a & b;

        // OR
        4'b0011:
            y = a | b;

        // XOR
        4'b0100:
            y = a ^ b;

        // SLL
        // RV32I uses only shamt[4:0]
        4'b0101:
            y = a << b[4:0];

        // SRL
        4'b0110:
            y = a >> b[4:0];

        // SRA
        4'b0111:
            y = $signed(a) >>> b[4:0];

        // SLT
        4'b1000:
            y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;

        // SLTU
        4'b1001:
            y = (a < b) ? 32'd1 : 32'd0;

        // Default
        default:
            y = 32'b0;

    endcase

end

endmodule