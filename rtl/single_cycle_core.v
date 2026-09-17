module single_cycle_core (
    input clk,
    input rst
);

    // ==========================================
    // PC
    // ==========================================
    wire [31:0] pc;
    wire [31:0] next_pc;

    assign next_pc = pc + 32'd4;

    program_counter pc_unit (
        .clk(clk),
        .rst(rst),
        .pc(pc)
    );


    // ==========================================
    // Instruction Memory
    // ==========================================
    wire [31:0] instruction;

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );


    // ==========================================
    // Instruction Decoder
    // ==========================================
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [6:0] opcode;
    wire [2:0] func3;
    wire [6:0] func7;

    wire [3:0] decoder_alu_op;
    wire [2:0] imm_type;

    instruction_decoder decoder (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .alu_op(decoder_alu_op),
        .imm_type(imm_type)
    );


    // ==========================================
    // Control Unit
    // ==========================================
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire jump;
    wire [1:0] alu_op;

    control_unit control (
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .alu_op(alu_op)
    );


    // ==========================================
    // Register File
    // ==========================================
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] write_back_data;

    register_file registers (
        .clk(clk),
        .write_enable(reg_write),
        .write_addr(rd),
        .write_data(write_back_data),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );


    // ==========================================
    // Immediate Generator
    // ==========================================
    wire [31:0] immediate;

    immediate_generator imm_gen (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );


    // ==========================================
    // ALU Control
    // ==========================================
    wire [3:0] alu_operation;

    alu_control alu_ctrl (
        .alu_op(alu_op),
        .func3(func3),
        .func7(func7),
        .alu_control(alu_operation)
    );


    // ==========================================
    // ALU Input MUX
    // ==========================================
    wire [31:0] alu_input_b;

    mux2_1_32bit alu_mux (
        .a(read_data2),
        .b(immediate),
        .sel(alu_src),
        .y(alu_input_b)
    );


    // ==========================================
    // ALU
    // ==========================================
    wire [31:0] alu_result;

    alu processor_alu (
        .a(read_data1),
        .b(alu_input_b),
        .op(alu_operation),
        .y(alu_result)
    );


    // ==========================================
    // Data Memory
    // ==========================================
    wire [31:0] memory_data;

    data_memory dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(memory_data)
    );


    // ==========================================
    // Write-Back MUX
    // ==========================================
    mux2_1_32bit wb_mux (
        .a(alu_result),
        .b(memory_data),
        .sel(mem_to_reg),
        .y(write_back_data)
    );

endmodule