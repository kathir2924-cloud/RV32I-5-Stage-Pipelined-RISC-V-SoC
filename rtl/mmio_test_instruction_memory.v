`timescale 1ns/1ps

module mmio_test_instruction_memory (
    input  wire [31:0] address,
    output reg  [31:0] instruction
);

    always @(*) begin

        case (address)

            // x1 = 0x10000000
            32'h00000000: instruction = 32'h100000B7;

            // x2 = 0x12345678
            32'h00000004: instruction = 32'h12345137;
            32'h00000008: instruction = 32'h67810113;

            // SW x2, 0(x1)
            32'h0000000C: instruction = 32'h0020A023;

            // LW x3, 0(x1)
            32'h00000010: instruction = 32'h0000A183;

            // NOP
            32'h00000014: instruction = 32'h00000013;
            32'h00000018: instruction = 32'h00000013;
            32'h0000001C: instruction = 32'h00000013;

            default:
                instruction = 32'h00000013;

        endcase

    end

endmodule