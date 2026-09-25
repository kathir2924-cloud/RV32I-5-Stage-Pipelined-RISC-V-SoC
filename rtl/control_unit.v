module control_unit (
    input  [6:0]  opcode,
    input  [2:0]  func3,
    input  [6:0]  func7,
    input  [31:0] instruction,

    output reg       reg_write,
    output reg       mem_read,
    output reg       mem_write,
    output reg       mem_to_reg,
    output reg       alu_src,
    output reg       branch,
    output reg       jump,
    output reg       jalr,

    output reg       lui,
    output reg       auipc,

    output reg       csr_read,
    output reg       csr_write,

    output reg       trap_enter,
    output reg       mret,
    output reg [31:0] trap_cause,

    output reg [1:0] alu_op
);


always @(*) begin

    // =========================================================
    // DEFAULTS
    // =========================================================

    reg_write  = 1'b0;
    mem_read   = 1'b0;
    mem_write  = 1'b0;
    mem_to_reg = 1'b0;

    alu_src    = 1'b0;

    branch     = 1'b0;
    jump       = 1'b0;
    jalr       = 1'b0;

    lui        = 1'b0;
    auipc      = 1'b0;

    csr_read   = 1'b0;
    csr_write  = 1'b0;

    trap_enter = 1'b0;
    mret       = 1'b0;
    trap_cause = 32'b0;

    alu_op     = 2'b00;


    case (opcode)

        // =====================================================
        // R-TYPE
        // =====================================================

        7'b0110011: begin

            case (func3)

                3'b000: begin
                    if ((func7 == 7'b0000000) ||
                        (func7 == 7'b0100000)) begin

                        reg_write = 1'b1;
                        alu_op    = 2'b10;

                    end
                    else begin
                        trap_enter = 1'b1;
                        trap_cause = 32'd2;
                    end
                end

                3'b001,
                3'b010,
                3'b011,
                3'b100,
                3'b110,
                3'b111: begin

                    if (func7 == 7'b0000000) begin
                        reg_write = 1'b1;
                        alu_op    = 2'b10;
                    end
                    else begin
                        trap_enter = 1'b1;
                        trap_cause = 32'd2;
                    end

                end

                3'b101: begin

                    if ((func7 == 7'b0000000) ||
                        (func7 == 7'b0100000)) begin

                        reg_write = 1'b1;
                        alu_op    = 2'b10;

                    end
                    else begin
                        trap_enter = 1'b1;
                        trap_cause = 32'd2;
                    end

                end

                default: begin
                    trap_enter = 1'b1;
                    trap_cause = 32'd2;
                end

            endcase

        end


        // =====================================================
        // I-TYPE ALU
        // =====================================================

        7'b0010011: begin

            case (func3)

                3'b000,
                3'b010,
                3'b011,
                3'b100,
                3'b110,
                3'b111: begin

                    reg_write = 1'b1;
                    alu_src   = 1'b1;
                    alu_op    = 2'b11;

                end

                // SLLI
                3'b001: begin

                    if (func7 == 7'b0000000) begin

                        reg_write = 1'b1;
                        alu_src   = 1'b1;
                        alu_op    = 2'b11;

                    end
                    else begin
                        trap_enter = 1'b1;
                        trap_cause = 32'd2;
                    end

                end

                // SRLI / SRAI
                3'b101: begin

                    if ((func7 == 7'b0000000) ||
                        (func7 == 7'b0100000)) begin

                        reg_write = 1'b1;
                        alu_src   = 1'b1;
                        alu_op    = 2'b11;

                    end
                    else begin
                        trap_enter = 1'b1;
                        trap_cause = 32'd2;
                    end

                end

                default: begin
                    trap_enter = 1'b1;
                    trap_cause = 32'd2;
                end

            endcase

        end


        // =====================================================
        // LW
        // =====================================================

        7'b0000011: begin

            if (func3 == 3'b010) begin

                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_src    = 1'b1;
                alu_op     = 2'b00;

            end
            else begin

                trap_enter = 1'b1;
                trap_cause = 32'd2;

            end

        end


        // =====================================================
        // SW
        // =====================================================

        7'b0100011: begin

            if (func3 == 3'b010) begin

                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;

            end
            else begin

                trap_enter = 1'b1;
                trap_cause = 32'd2;

            end

        end


        // =====================================================
        // BRANCH
        // =====================================================

        7'b1100011: begin

            case (func3)

                3'b000,
                3'b001,
                3'b100,
                3'b101,
                3'b110,
                3'b111: begin

                    branch  = 1'b1;
                    alu_op  = 2'b01;

                end

                default: begin

                    trap_enter = 1'b1;
                    trap_cause = 32'd2;

                end

            endcase

        end


        // =====================================================
        // LUI
        // =====================================================

        7'b0110111: begin

            reg_write = 1'b1;
            alu_src   = 1'b1;
            lui       = 1'b1;
            alu_op    = 2'b00;

        end


        // =====================================================
        // AUIPC
        // =====================================================

        7'b0010111: begin

            reg_write = 1'b1;
            alu_src   = 1'b1;
            auipc     = 1'b1;
            alu_op    = 2'b00;

        end


        // =====================================================
        // JAL
        // =====================================================

        7'b1101111: begin

            reg_write = 1'b1;
            jump      = 1'b1;

        end


        // =====================================================
        // JALR
        // =====================================================

        7'b1100111: begin

            if (func3 == 3'b000) begin

                reg_write = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;

            end
            else begin

                trap_enter = 1'b1;
                trap_cause = 32'd2;

            end

        end


        // =====================================================
        // SYSTEM / CSR
        // =====================================================

        7'b1110011: begin

            case (func3)

                // -------------------------------------------------
                // ECALL / EBREAK / MRET
                // -------------------------------------------------

                3'b000: begin

                    if (instruction == 32'h00000073) begin

                        // ECALL
                        trap_enter = 1'b1;
                        trap_cause = 32'd11;

                    end
                    else if (instruction == 32'h00100073) begin

                        // EBREAK
                        trap_enter = 1'b1;
                        trap_cause = 32'd3;

                    end
                    else if (instruction == 32'h30200073) begin

                        // MRET
                        mret = 1'b1;

                    end
                    else begin

                        // Illegal SYSTEM instruction
                        trap_enter = 1'b1;
                        trap_cause = 32'd2;

                    end

                end


                // -------------------------------------------------
                // CSRRW
                // -------------------------------------------------

                3'b001: begin

                    reg_write = 1'b1;
                    csr_read  = 1'b1;
                    csr_write = 1'b1;

                end


                // -------------------------------------------------
                // CSRRS
                // -------------------------------------------------

                3'b010: begin

                    reg_write = 1'b1;
                    csr_read  = 1'b1;
                    csr_write = 1'b1;

                end


                // -------------------------------------------------
                // CSRRC
                // -------------------------------------------------

                3'b011: begin

                    reg_write = 1'b1;
                    csr_read  = 1'b1;
                    csr_write = 1'b1;

                end


                // -------------------------------------------------
                // CSRRWI
                // -------------------------------------------------

                3'b101: begin

                    reg_write = 1'b1;
                    csr_read  = 1'b1;
                    csr_write = 1'b1;

                end


                // -------------------------------------------------
                // CSRRSI
                // -------------------------------------------------

                3'b110: begin

                    reg_write = 1'b1;
                    csr_read  = 1'b1;
                    csr_write = 1'b1;

                end


                // -------------------------------------------------
                // CSRRCI
                // -------------------------------------------------

                3'b111: begin

                    reg_write = 1'b1;
                    csr_read  = 1'b1;
                    csr_write = 1'b1;

                end


                default: begin

                    trap_enter = 1'b1;
                    trap_cause = 32'd2;

                end

            endcase

        end


        // =====================================================
        // ILLEGAL OPCODE
        // =====================================================

        default: begin

            trap_enter = 1'b1;
            trap_cause = 32'd2;

        end

    endcase

end

endmodule