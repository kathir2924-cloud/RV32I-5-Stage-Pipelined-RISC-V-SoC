module csr_test_instruction_memory (
    input  [31:0] address,
    output reg [31:0] instruction
);

    always @(*) begin

        case (address)

            // -------------------------------------------------
            // PC = 0
            // CSRRW x5, mscratch, x6
            // old mscratch -> x5
            // mscratch <- x6
            // -------------------------------------------------
            32'd0:
                instruction = {12'h340, 5'd6, 3'b001, 5'd5, 7'b1110011};


            // -------------------------------------------------
            // PC = 4
            // CSRRS x7, mscratch, x1
            // old mscratch -> x7
            // mscratch <- mscratch | x1
            // -------------------------------------------------
            32'd4:
                instruction = {12'h340, 5'd1, 3'b010, 5'd7, 7'b1110011};


            // -------------------------------------------------
            // PC = 8
            // CSRRC x8, mscratch, x1
            // old mscratch -> x8
            // mscratch <- mscratch & ~x1
            // -------------------------------------------------
            32'd8:
                instruction = {12'h340, 5'd1, 3'b011, 5'd8, 7'b1110011};


            // -------------------------------------------------
            // PC = 12
            // CSRRWI x9, mscratch, 5
            // old mscratch -> x9
            // mscratch <- 5
            // -------------------------------------------------
            32'd12:
                instruction = {12'h340, 5'd5, 3'b101, 5'd9, 7'b1110011};


            // -------------------------------------------------
            // PC = 16
            // CSRRSI x10, mscratch, 2
            // old mscratch -> x10
            // mscratch <- mscratch | 2
            // -------------------------------------------------
            32'd16:
                instruction = {12'h340, 5'd2, 3'b110, 5'd10, 7'b1110011};


            // -------------------------------------------------
            // PC = 20
            // CSRRCI x11, mscratch, 1
            // old mscratch -> x11
            // mscratch <- mscratch & ~1
            // -------------------------------------------------
            32'd20:
                instruction = {12'h340, 5'd1, 3'b111, 5'd11, 7'b1110011};


            // -------------------------------------------------
            // Default = NOP
            // -------------------------------------------------
            default:
                instruction = 32'h00000013;

        endcase

    end

endmodule