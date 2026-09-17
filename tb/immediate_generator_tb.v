module immediate_generator_tb;

reg [31:0] instruction;
reg [2:0] imm_type;

wire [31:0] immediate;


immediate_generator dut(
    .instruction(instruction),
    .imm_type(imm_type),
    .immediate(immediate)
);


initial begin

    // I-type
    // Immediate = 10
    instruction = 32'b00000000101000000000000000010011;
    imm_type = 3'b000;

    #10;

    // S-type
    // Example immediate
    instruction = 32'b00000000010100000010010000100011;
    imm_type = 3'b001;

    #10;

    // B-type
    instruction = 32'b00000000001000001000000001100011;
    imm_type = 3'b010;

    #10;

    // U-type
    instruction = 32'h12345037;
    imm_type = 3'b011;

    #10;

    // J-type
    instruction = 32'h0080006F;
    imm_type = 3'b100;

    #10;

    $finish;

end


initial begin

    $monitor("Time=%0t | Instruction=%h | Imm_Type=%b | Immediate=%h",
             $time,
             instruction,
             imm_type,
             immediate);

end

endmodule