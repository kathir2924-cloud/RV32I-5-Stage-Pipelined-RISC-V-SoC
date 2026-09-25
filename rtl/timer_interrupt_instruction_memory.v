`timescale 1ns/1ps

module timer_interrupt_instruction_memory (
    input  wire [31:0] address,
    output reg  [31:0] instruction
);

    always @(*) begin

        case (address)

            // ====================================================
            // MAIN PROGRAM
            // ====================================================

            // x3 = 0x100
            32'h00000000: instruction = 32'h10000193;

            // CSRRW x0, mtvec, x3
            32'h00000004: instruction = 32'h30519073;

            // x1 = 8
            // MSTATUS.MIE = 1
            32'h00000008: instruction = 32'h00800093;

            // CSRRW x0, mstatus, x1
            32'h0000000C: instruction = 32'h30009073;

            // x2 = 128
            // MIE.MTIE = 1
            32'h00000010: instruction = 32'h08000113;

            // CSRRW x0, mie, x2
            32'h00000014: instruction = 32'h30411073;

            // ====================================================
            // Wait for timer interrupt
            // ====================================================

            32'h00000018: instruction = 32'h00000013;
            32'h0000001C: instruction = 32'h00000013;
            32'h00000020: instruction = 32'h00000013;
            32'h00000024: instruction = 32'h00000013;
            32'h00000028: instruction = 32'h00000013;
            32'h0000002C: instruction = 32'h00000013;
            32'h00000030: instruction = 32'h00000013;
            32'h00000034: instruction = 32'h00000013;
            32'h00000038: instruction = 32'h00000013;
            32'h0000003C: instruction = 32'h00000013;
            32'h00000040: instruction = 32'h00000013;
            32'h00000044: instruction = 32'h00000013;
            32'h00000048: instruction = 32'h00000013;
            32'h0000004C: instruction = 32'h00000013;
            32'h00000050: instruction = 32'h00000013;

            // ====================================================
            // TIMER INTERRUPT HANDLER @ 0x100
            // ====================================================

            // x5 = mcause
            32'h00000100: instruction = 32'h342022F3;

            // x6 = mepc
            32'h00000104: instruction = 32'h34102373;

            // Return from interrupt
            32'h00000108: instruction = 32'h30200073;

            // ====================================================
            // DEFAULT = NOP
            // ====================================================

            default:
                instruction = 32'h00000013;

        endcase

    end

endmodule