`timescale 1ns/1ps

module mmio_uart_rx_test_instruction_memory (
    input wire [31:0] address,
    output reg [31:0] instruction
);

    always @(*) begin

        case (address)

            // x1 = 0x10000000
            32'h00000000: instruction = 32'h100000B7;

            // ------------------------------------------------
            // Wait for UART RX to finish receiving the byte.
            // Each NOP = 1 CPU cycle.
            // ------------------------------------------------

            32'h00000004: instruction = 32'h00000013;
            32'h00000008: instruction = 32'h00000013;
            32'h0000000C: instruction = 32'h00000013;
            32'h00000010: instruction = 32'h00000013;
            32'h00000014: instruction = 32'h00000013;
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
            32'h00000054: instruction = 32'h00000013;
            32'h00000058: instruction = 32'h00000013;
            32'h0000005C: instruction = 32'h00000013;
            32'h00000060: instruction = 32'h00000013;
            32'h00000064: instruction = 32'h00000013;
            32'h00000068: instruction = 32'h00000013;
            32'h0000006C: instruction = 32'h00000013;
            32'h00000070: instruction = 32'h00000013;
            32'h00000074: instruction = 32'h00000013;
            32'h00000078: instruction = 32'h00000013;
            32'h0000007C: instruction = 32'h00000013;
            32'h00000080: instruction = 32'h00000013;
            32'h00000084: instruction = 32'h00000013;
            32'h00000088: instruction = 32'h00000013;
            32'h0000008C: instruction = 32'h00000013;
            32'h00000090: instruction = 32'h00000013;
            32'h00000094: instruction = 32'h00000013;
            32'h00000098: instruction = 32'h00000013;
            32'h0000009C: instruction = 32'h00000013;
            32'h000000A0: instruction = 32'h00000013;
            32'h000000A4: instruction = 32'h00000013;
            32'h000000A8: instruction = 32'h00000013;
            32'h000000AC: instruction = 32'h00000013;
            32'h000000B0: instruction = 32'h00000013;
            32'h000000B4: instruction = 32'h00000013;
            32'h000000B8: instruction = 32'h00000013;
            32'h000000BC: instruction = 32'h00000013;
            32'h000000C0: instruction = 32'h00000013;
            32'h000000C4: instruction = 32'h00000013;
            32'h000000C8: instruction = 32'h00000013;
            32'h000000CC: instruction = 32'h00000013;
            32'h000000D0: instruction = 32'h00000013;
            32'h000000D4: instruction = 32'h00000013;
            32'h000000D8: instruction = 32'h00000013;
            32'h000000DC: instruction = 32'h00000013;
            32'h000000E0: instruction = 32'h00000013;
            32'h000000E4: instruction = 32'h00000013;
            32'h000000E8: instruction = 32'h00000013;
            32'h000000EC: instruction = 32'h00000013;
            32'h000000F0: instruction = 32'h00000013;
            32'h000000F4: instruction = 32'h00000013;

            // ------------------------------------------------
            // After UART reception, read UART RX MMIO
            //
            // x1 = 0x10000000
            // LW x3, 8(x1)
            // address = 0x10000008
            // ------------------------------------------------

            32'h000000F8: instruction = 32'h0080A183;

            // NOPs
            32'h000000FC: instruction = 32'h00000013;
            32'h00000100: instruction = 32'h00000013;
            32'h00000104: instruction = 32'h00000013;
            32'h00000108: instruction = 32'h00000013;

            default:
                instruction = 32'h00000013;

        endcase

    end

endmodule