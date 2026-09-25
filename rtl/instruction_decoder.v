module instruction_decoder (
    input  [31:0] instruction,

    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,

    output [6:0] opcode,
    output [2:0] func3,
    output [6:0] func7,

    output reg [3:0] alu_op,
    output reg [2:0] imm_type,

    // =========================================================
    // CSR DECODE OUTPUTS
    // =========================================================

    output reg        csr_read,
    output reg        csr_write,
    output reg [11:0] csr_addr,
    output reg [2:0]  csr_op,
    output reg [4:0]  csr_imm,
    output reg        csr_use_imm
);


// =============================================================
// INSTRUCTION FIELD EXTRACTION
// =============================================================

assign opcode = instruction[6:0];

assign rd     = instruction[11:7];

assign func3  = instruction[14:12];

assign rs1    = instruction[19:15];

assign rs2    = instruction[24:20];

assign func7  = instruction[31:25];


// =============================================================
// DECODER
// =============================================================

always @(*) begin

    // ---------------------------------------------------------
    // DEFAULT VALUES
    // ---------------------------------------------------------

    alu_op   = 4'b0000;
    imm_type = 3'b000;

    // CSR defaults
    csr_read    = 1'b0;
    csr_write   = 1'b0;
    csr_addr    = 12'b0;
    csr_op      = 3'b000;
    csr_imm     = 5'b0;
    csr_use_imm = 1'b0;


    case (opcode)

        // =====================================================
        // R-TYPE
        // =====================================================

        7'b0110011: begin

            case (func3)

                3'b000: begin
                    if (func7 == 7'b0100000)
                        alu_op = 4'b0001;
                    else
                        alu_op = 4'b0000;
                end

                3'b001:
                    alu_op = 4'b0101;

                3'b010:
                    alu_op = 4'b1000;

                3'b011:
                    alu_op = 4'b1001;

                3'b100:
                    alu_op = 4'b0100;

                3'b101: begin
                    if (func7 == 7'b0100000)
                        alu_op = 4'b0111;
                    else
                        alu_op = 4'b0110;
                end

                3'b110:
                    alu_op = 4'b0011;

                3'b111:
                    alu_op = 4'b0010;

                default:
                    alu_op = 4'b0000;

            endcase

        end


        // =====================================================
        // I-TYPE ALU
        // =====================================================

        7'b0010011: begin

            imm_type = 3'b000;

            case (func3)

                3'b000:
                    alu_op = 4'b0000;

                3'b001:
                    alu_op = 4'b0101;

                3'b010:
                    alu_op = 4'b1000;

                3'b011:
                    alu_op = 4'b1001;

                3'b100:
                    alu_op = 4'b0100;

                3'b101: begin
                    if (func7 == 7'b0100000)
                        alu_op = 4'b0111;
                    else
                        alu_op = 4'b0110;
                end

                3'b110:
                    alu_op = 4'b0011;

                3'b111:
                    alu_op = 4'b0010;

                default:
                    alu_op = 4'b0000;

            endcase

        end


        // =====================================================
        // LOAD
        // =====================================================

        7'b0000011: begin

            imm_type = 3'b000;
            alu_op   = 4'b0000;

        end


        // =====================================================
        // STORE
        // =====================================================

        7'b0100011: begin

            imm_type = 3'b001;
            alu_op   = 4'b0000;

        end


        // =====================================================
        // BRANCH
        // =====================================================

        7'b1100011: begin

            imm_type = 3'b010;
            alu_op   = 4'b0001;

        end


        // =====================================================
        // LUI
        // =====================================================

        7'b0110111: begin

            imm_type = 3'b011;
            alu_op   = 4'b0000;

        end


        // =====================================================
        // AUIPC
        // =====================================================

        7'b0010111: begin

            imm_type = 3'b011;
            alu_op   = 4'b0000;

        end


        // =====================================================
        // JAL
        // =====================================================

        7'b1101111: begin

            imm_type = 3'b100;
            alu_op   = 4'b0000;

        end


        // =====================================================
        // JALR
        // =====================================================

        7'b1100111: begin

            imm_type = 3'b000;
            alu_op   = 4'b0000;

        end


        // =====================================================
        // CSR INSTRUCTIONS
        // Opcode = 1110011
        // =====================================================

        7'b1110011: begin

            // CSR address = instruction[31:20]
            csr_addr = instruction[31:20];

            // CSR operation = func3
            csr_op = func3;

            // Immediate CSR variants use rs1 field as zimm
            csr_imm = instruction[19:15];

            // Read CSR for all six CSR register operations
            csr_read = 1'b1;

            case (func3)

                // CSRRW
                3'b001: begin
                    csr_write   = 1'b1;
                    csr_use_imm = 1'b0;
                end

                // CSRRS
                3'b010: begin
                    csr_write   = 1'b1;
                    csr_use_imm = 1'b0;
                end

                // CSRRC
                3'b011: begin
                    csr_write   = 1'b1;
                    csr_use_imm = 1'b0;
                end

                // CSRRWI
                3'b101: begin
                    csr_write   = 1'b1;
                    csr_use_imm = 1'b1;
                end

                // CSRRSI
                3'b110: begin
                    csr_write   = 1'b1;
                    csr_use_imm = 1'b1;
                end

                // CSRRCI
                3'b111: begin
                    csr_write   = 1'b1;
                    csr_use_imm = 1'b1;
                end

                default: begin
                    csr_read    = 1'b0;
                    csr_write   = 1'b0;
                    csr_use_imm = 1'b0;
                end

            endcase

        end


        // =====================================================
        // DEFAULT
        // =====================================================

        default: begin

            alu_op   = 4'b0000;
            imm_type = 3'b000;

        end

    endcase

end

endmodule