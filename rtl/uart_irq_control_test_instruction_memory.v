`timescale 1ns/1ps

module uart_irq_control_test_instruction_memory (
    input  wire [31:0] address,
    output reg  [31:0] instruction
);

    always @(*) begin
        case (address)

            // x1 = 1
            32'h00000000: instruction = 32'h00100093; // ADDI x1,x0,1

            // x2 = 0x10000000
            32'h00000004: instruction = 32'h10000137; // LUI x2,0x10000

            // CONTROL = 1
            32'h00000008: instruction = 32'h00112A23; // SW x1,20(x2)

            // Wait
            32'h0000000C: instruction = 32'h00000013; // NOP
            32'h00000010: instruction = 32'h00000013; // NOP
            32'h00000014: instruction = 32'h00000013; // NOP
            32'h00000018: instruction = 32'h00000013; // NOP

            // x1 = 0
            32'h0000001C: instruction = 32'h00000093; // ADDI x1,x0,0

            // CONTROL = 0
            32'h00000020: instruction = 32'h00112A23; // SW x1,20(x2)

            // Wait
            32'h00000024: instruction = 32'h00000013;
            32'h00000028: instruction = 32'h00000013;
            32'h0000002C: instruction = 32'h00000013;

            default:
                instruction = 32'h00000013; // NOP

        endcase
    end

endmodule