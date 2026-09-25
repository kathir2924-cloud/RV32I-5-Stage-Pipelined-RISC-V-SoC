`timescale 1ns/1ps

module riscv_interrupt_priority_instruction_memory (
    input  wire [31:0] address,
    output reg  [31:0] instruction
);

    always @(*) begin
        case (address)

            // ====================================================
            // INTERRUPT CONFIGURATION
            // ====================================================

            32'h00000000:
                instruction = 32'h10000093;
                // ADDI x1, x0, 0x100
                // x1 = 0x100

            32'h00000004:
                instruction = 32'h30509073;
                // CSRW mtvec, x1
                // mtvec = 0x100

            32'h00000008:
                instruction = 32'h00800113;
                // ADDI x2, x0, 8
                // x2 = 8
                // MSTATUS.MIE

            32'h0000000C:
                instruction = 32'h30011073;
                // CSRW mstatus, x2
                // Enable machine interrupts

            32'h00000010:
                instruction = 32'h00811113;
                // ADDI x2, x2, 8 << 8
                // x2 = 0x800

            32'h00000014:
                instruction = 32'h30411073;
                // CSRW mie, x2
                // Enable UART external interrupt MIE[11]

            32'h00000018:
                instruction = 32'h10000237;
                // LUI x4, 0x10000
                // x4 = 0x10000000

            32'h0000001C:
                instruction = 32'h00100293;
                // ADDI x5, x0, 1
                // x5 = 1

            32'h00000020:
                instruction = 32'h00522A23;
                // SW x5, 20(x4)
                // CONTROL = 1
                // UART RX interrupt enable

            // ====================================================
            // WAIT FOR BOTH INTERRUPTS
            // ====================================================

            32'h00000024:
                instruction = 32'h00000013; // NOP

            32'h00000028:
                instruction = 32'h00000013; // NOP

            32'h0000002C:
                instruction = 32'h00000013; // NOP

            32'h00000030:
                instruction = 32'h00000013; // NOP

            32'h00000034:
                instruction = 32'h00000013; // NOP

            32'h00000038:
                instruction = 32'h00000013; // NOP

            32'h0000003C:
                instruction = 32'hFFDFF06F;
                // JAL x0, -4
                // Infinite loop

            // ====================================================
            // INTERRUPT HANDLER
            // ====================================================

            32'h00000100:
                instruction = 32'h34202373;
                // CSRR x6, mcause
                // x6 = mcause

            32'h00000104:
                instruction = 32'h100003B7;
                // LUI x7, 0x10000
                // x7 = 0x10000000

            32'h00000108:
                instruction = 32'h0083A403;
                // LW x8, 8(x7)
                // Read UART RX
                // Clears UART RX interrupt pending latch

            32'h0000010C:
                instruction = 32'h30200073;
                // MRET

            default:
                instruction = 32'h00000013;

        endcase
    end

endmodule