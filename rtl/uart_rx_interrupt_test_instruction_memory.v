`timescale 1ns/1ps

module uart_rx_interrupt_test_instruction_memory (
    input wire [31:0] address,
    output reg [31:0] instruction
);

    always @(*) begin

        case (address)

            // ============================================
            // UART RX INTERRUPT CONFIGURATION
            // ============================================

            // x1 = 0x100
            32'h00000000: instruction = 32'h10000093;

            // mtvec = x1
            32'h00000004: instruction = 32'h30509073;

            // x2 = 8
            32'h00000008: instruction = 32'h00800113;

            // mstatus = 8
            // MSTATUS.MIE = 1
            32'h0000000C: instruction = 32'h30011073;

            // x2 = x2 << 8
            // 8 << 8 = 0x800
            32'h00000010: instruction = 32'h00811113;

            // mie = 0x800
            // MIE[11] = MEIE = 1
            32'h00000014: instruction = 32'h30411073;

            // x4 = 0x10000000
            32'h00000018: instruction = 32'h10000237;

            // x5 = 1
            32'h0000001C: instruction = 32'h00100293;

            // SW x5,20(x4)
            // CONTROL address = 0x10000014
            // CONTROL bit 0 = 1
            32'h00000020: instruction = 32'h00522A23;

            // ============================================
            // WAIT FOR UART INTERRUPT
            // ============================================

            32'h00000024: instruction = 32'h00000013;
            32'h00000028: instruction = 32'h00000013;
            32'h0000002C: instruction = 32'h00000013;
            32'h00000030: instruction = 32'h00000013;
            32'h00000034: instruction = 32'h00000013;
            32'h00000038: instruction = 32'h00000013;

            // Infinite loop
            32'h0000003C: instruction = 32'hFFDFF06F;

            // ============================================
            // UART RX MACHINE EXTERNAL INTERRUPT HANDLER
            // ============================================

            // x6 = MCAUSE
            32'h00000100: instruction = 32'h34202373;

            // x7 = UART RX base address
            32'h00000104: instruction = 32'h100003B7;

            // x8 = UART RX data
            // LW x8, 8(x7)
            32'h00000108: instruction = 32'h0083A403;

            // MRET
            32'h0000010C: instruction = 32'h30200073;

            default:
                instruction = 32'h00000013;

        endcase

    end

endmodule