module instruction_memory (
    input  [31:0] address,
    output reg [31:0] instruction
);

always @(*) begin

    case (address)

        // ============================================================
        // BASIC ARITHMETIC / LOGICAL TESTS
        // ============================================================

        // ADDI x1, x0, 10
        // x1 = 10
        32'd0:
            instruction = 32'h00A00093;

        // ADDI x2, x0, 20
        // x2 = 20
        32'd4:
            instruction = 32'h01400113;

        // ADD x3, x1, x2
        // x3 = 30
        32'd8:
            instruction = 32'h002081B3;

        // SUB x4, x2, x1
        // x4 = 10
        32'd12:
            instruction = 32'h40110233;

        // AND x5, x1, x2
        // x5 = 0
        32'd16:
            instruction = 32'h0020F2B3;

        // OR x6, x1, x2
        // x6 = 30
        32'd20:
            instruction = 32'h0020E333;

        // XOR x7, x1, x2
        // x7 = 30
        32'd24:
            instruction = 32'h0020C3B3;


        // ============================================================
        // STORE / LOAD + LOAD-USE HAZARD
        // ============================================================

        // SW x3, 0(x0)
        // MEM[0] = x3 = 30
        32'd28:
            instruction = 32'h00302023;

        // LW x8, 0(x0)
        // x8 = 30
        32'd32:
            instruction = 32'h00002403;

        // ADD x9, x8, x1
        // x9 = 30 + 10 = 40
        32'd36:
            instruction = 32'h001404B3;


        // ============================================================
        // SLT / SLTU
        // ============================================================

        // SLT x10, x1, x2
        // 10 < 20 -> 1
        32'd40:
            instruction = 32'h0020A533;

        // SLTU x11, x1, x2
        // 10 < 20 -> 1
        32'd44:
            instruction = 32'h0020B5B3;


        // ============================================================
        // BEQ - NOT TAKEN
        // ============================================================

        // BEQ x1, x2, +12
        // 10 != 20 -> NOT TAKEN
        32'd48:
            instruction = 32'h00208663;

        // ADDI x12, x0, 111
        32'd52:
            instruction = 32'h06F00613;

        // ADDI x12, x0, 222
        32'd56:
            instruction = 32'h0DE00613;

        // ADDI x12, x0, 777
        // Final x12 = 777
        32'd60:
            instruction = 32'h30900613;


        // ============================================================
        // JAL
        // ============================================================

        // JAL x13, +16
        // PC 64 -> PC 80
        // x13 = PC + 4 = 68
        32'd64:
            instruction = 32'h010006EF;

        // Flushed instruction
        32'd68:
            instruction = 32'h06F00713;

        // Flushed instruction
        32'd72:
            instruction = 32'h0DE00713;

        // Flushed instruction
        32'd76:
            instruction = 32'h14D00713;

        // Target
        // ADDI x14, x0, 999
        32'd80:
            instruction = 32'h3E700713;


        // ============================================================
        // JALR
        // ============================================================

        // ADDI x15, x0, 100
        32'd84:
            instruction = 32'h06400793;

        // JALR x16, x15, 4
        // Target = 100 + 4 = 104
        // x16 = PC + 4 = 92
        32'd88:
            instruction = 32'h00478867;

        // Flushed instruction
        32'd92:
            instruction = 32'h06F00813;

        // Flushed instruction
        32'd96:
            instruction = 32'h0DE00813;

        // Flushed instruction
        32'd100:
            instruction = 32'h14D00813;

        // Target
        32'd104:
            instruction = 32'h3E700813;


        // ============================================================
        // LUI
        // ============================================================

        // LUI x17, 0x12345
        // x17 = 0x12345000
        32'd108:
            instruction = 32'h123458B7;


        // ============================================================
        // AUIPC
        // ============================================================

        // AUIPC x18, 0x1
        // PC = 0x70
        // x18 = 0x70 + 0x1000
        //     = 0x00001070
        32'd112:
            instruction = 32'h00001917;


        // ============================================================
        // BNE
        // ============================================================

        // BNE x1, x2, +8
        // 10 != 20 -> TAKEN
        // PC 116 -> PC 124
        32'd116:
            instruction = 32'h00209463;

        // Flushed
        // ADDI x19, x0, 1
        32'd120:
            instruction = 32'h00100993;

        // Target
        // ADDI x19, x0, 2
        32'd124:
            instruction = 32'h00200993;


        // ============================================================
        // BLT
        // ============================================================

        // BLT x1, x2, +8
        // 10 < 20 -> TAKEN
        32'd128:
            instruction = 32'h0020C463;

        // Flushed
        32'd132:
            instruction = 32'h00100A13;

        // Target
        32'd136:
            instruction = 32'h00200A13;


        // ============================================================
        // BGE
        // ============================================================

        // BGE x2, x1, +8
        // 20 >= 10 -> TAKEN
        32'd140:
            instruction = 32'h00115463;

        // Flushed
        32'd144:
            instruction = 32'h00100A93;

        // Target
        32'd148:
            instruction = 32'h00200A93;


        // ============================================================
        // BLTU
        // ============================================================

        // BLTU x1, x2, +8
        // 10 < 20 -> TAKEN
        32'd152:
            instruction = 32'h0020E463;

        // Flushed
        32'd156:
            instruction = 32'h00100B13;

        // Target
        32'd160:
            instruction = 32'h00200B13;


        // ============================================================
        // BGEU
        // ============================================================

        // BGEU x2, x1, +8
        // 20 >= 10 -> TAKEN
        32'd164:
            instruction = 32'h00117463;

        // Flushed
        32'd168:
            instruction = 32'h00100B93;

        // Target
        32'd172:
            instruction = 32'h00200B93;


        // ============================================================
        // I-TYPE ALU TESTS
        // ============================================================

        // ADDI x24, x0, 15
        // x24 = 15
        32'd176:
            instruction = 32'h00F00C13;

        // ANDI x25, x1, 6
        // 10 & 6 = 2
        32'd180:
            instruction = 32'h0060FC93;

        // ORI x26, x1, 5
        // 10 | 5 = 15
        32'd184:
            instruction = 32'h0050ED13;

        // XORI x27, x1, 15
        // 10 ^ 15 = 5
        32'd188:
            instruction = 32'h00F0CD93;

        // SLTI x28, x1, 20
        // 10 < 20 -> 1
        32'd192:
            instruction = 32'h0140AE13;

        // SLTIU x29, x1, 20
        // 10 < 20 -> 1
        32'd196:
            instruction = 32'h0140BE93;

        // SLLI x30, x1, 2
        // 10 << 2 = 40
        32'd200:
            instruction = 32'h00209F13;

        // SRLI x31, x2, 2
        // 20 >> 2 = 5
        32'd204:
            instruction = 32'h00215F93;

        // SRAI x17, x2, 2
        // 20 >>> 2 = 5
        32'd208:
            instruction = 32'h40215893;

        // Restore x17 after SRAI test
        // LUI x17, 0x12345
        32'd212:
            instruction = 32'h123458B7;


                      // ============================================================
        // SIGNED / UNSIGNED EDGE-CASE TESTS
        // ============================================================

        // ADDI x19, x0, -8
        // x19 = 0xFFFFFFF8 (-8 signed)
        32'd216:
            instruction = 32'hFF800993;

        // SLTI x20, x19, 0
        // Signed comparison:
        // -8 < 0 -> 1
        32'd220:
            instruction = 32'h0009AA13;

        // SLTIU x21, x19, 0
        // Unsigned comparison:
        // 0xFFFFFFF8 < 0x00000000 -> 0
        32'd224:
            instruction = 32'h0009BA93;

        // SRAI x22, x19, 2
        // Arithmetic right shift:
        // 0xFFFFFFF8 >>> 2 = 0xFFFFFFFE
        32'd228:
            instruction = 32'h4029DB13;

        // SRLI x23, x19, 2
        // Logical right shift:
        // 0xFFFFFFF8 >> 2 = 0x3FFFFFFE
        32'd232:
            instruction = 32'h0029DB93;


        // ============================================================
        // RESTORE BRANCH TEST RESULTS
        // ============================================================

        // ADDI x19, x0, 2
        32'd236:
            instruction = 32'h00200993;

        // ADDI x20, x0, 2
        32'd240:
            instruction = 32'h00200A13;

        // ADDI x21, x0, 2
        32'd244:
            instruction = 32'h00200A93;

        // ADDI x22, x0, 2
        32'd248:
            instruction = 32'h00200B13;

        // ADDI x23, x0, 2
        32'd252:
            instruction = 32'h00200B93;

        // NOP
        32'd256:
            instruction = 32'h00000013;

        32'd260:
            instruction = 32'h00000013;

        32'd264:
            instruction = 32'h00000013;

        32'd268:
            instruction = 32'h00000013;

        32'd272:
            instruction = 32'h00000013;

        32'd276:
            instruction = 32'h00000013;

        32'd280:
            instruction = 32'h00000013;
        // ============================================================
        // DEFAULT NOP
        // ============================================================

        default:
            instruction = 32'h00000013;

    endcase

end

endmodule