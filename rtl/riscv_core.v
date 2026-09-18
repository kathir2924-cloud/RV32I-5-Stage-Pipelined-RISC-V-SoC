module riscv_core (
    input clk,
    input rst
);

    // ============================================================
    // IF STAGE
    // ============================================================

    wire [31:0] pc;
    wire [31:0] instruction;

    wire pc_write;
    wire pc_write_final;
    wire [31:0] next_pc;

    wire control_transfer;

    wire branch_taken;
    wire jump_taken;

    wire [31:0] branch_target;
    wire [31:0] jump_target;

    assign control_transfer = branch_taken | jump_taken;

    assign pc_write_final =
    control_transfer ? 1'b1 : pc_write;


    // ============================================================
    // PC
    // ============================================================

    pc_next_logic pc_logic (
        .pc(pc),
        .target_address(
            jump_taken ? jump_target : branch_target
        ),
        .control_transfer(control_transfer),
        .next_pc(next_pc)
    );

    program_counter_enable pc_unit (
    .clk(clk),
    .rst(rst),
    .enable(pc_write_final),
    .next_pc(next_pc),
    .pc(pc)
);


    // ============================================================
    // INSTRUCTION MEMORY
    // ============================================================

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );


    // ============================================================
    // IF/ID
    // ============================================================

    wire [31:0] id_pc;
    wire [31:0] id_instruction;

    wire if_id_write;

    wire flush_if_id;
    wire flush_id_ex;


    pipeline_flush_control flush_control (
        .control_transfer(control_transfer),
        .flush_if_id(flush_if_id),
        .flush_id_ex(flush_id_ex)
    );


    pipeline_if_id if_id (
        .clk(clk),
        .rst(rst),
        .enable(if_id_write),
        .flush(flush_if_id),

        .pc_in(pc),
        .instruction_in(instruction),

        .pc_out(id_pc),
        .instruction_out(id_instruction)
    );


    // ============================================================
    // DECODER
    // ============================================================

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    wire [6:0] opcode;
    wire [2:0] func3;
    wire [6:0] func7;

    wire [3:0] decoder_alu_op;
    wire [2:0] imm_type;


    instruction_decoder decoder (
        .instruction(id_instruction),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .opcode(opcode),
        .func3(func3),
        .func7(func7),

        .alu_op(decoder_alu_op),
        .imm_type(imm_type)
    );


    // ============================================================
    // CONTROL UNIT
    // ============================================================

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire jump;
    wire jalr;
    wire lui;
wire auipc;


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
        .jalr(jalr),
        .lui(lui),
.auipc(auipc),

        .alu_op(alu_op)
    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] write_back_data;

    wire [4:0] wb_rd;
    wire wb_reg_write;


    register_file registers (
        .clk(clk),

        .write_enable(wb_reg_write),
        .write_addr(wb_rd),
        .write_data(write_back_data),

        .read_addr1(rs1),
        .read_addr2(rs2),

        .read_data1(read_data1),
        .read_data2(read_data2)
    );


    // ============================================================
    // IMMEDIATE
    // ============================================================

    wire [31:0] immediate;


    immediate_generator imm_gen (
        .instruction(id_instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );


    // ============================================================
    // HAZARD DETECTION
    // ============================================================

    wire stall;

    wire [4:0] ex_rd;
    wire ex_mem_read;


    hazard_detection_unit hazard_unit (
        .id_ex_mem_read(ex_mem_read),
        .id_ex_rd(ex_rd),

        .if_id_rs1(rs1),
        .if_id_rs2(rs2),

        .stall(stall)
    );


    // ============================================================
    // STALL CONTROL
    // ============================================================

    wire control_mux_select;


    hazard_stall_control stall_control (
        .stall(stall),

        .pc_write(pc_write),
        .if_id_write(if_id_write),

        .control_mux_select(control_mux_select)
    );


    // ============================================================
    // ID/EX CONTROL
    // ============================================================

    wire id_ex_reg_write_in;
    wire id_ex_mem_read_in;
    wire id_ex_mem_write_in;
    wire id_ex_mem_to_reg_in;
    wire id_ex_alu_src_in;
    wire id_ex_branch_in;
    wire id_ex_jump_in;
    wire id_ex_jalr_in;
    wire id_ex_lui_in;
wire id_ex_auipc_in;

    wire [1:0] id_ex_alu_op_in;


    assign id_ex_reg_write_in =
        control_mux_select ? 1'b0 : reg_write;

    assign id_ex_mem_read_in =
        control_mux_select ? 1'b0 : mem_read;

    assign id_ex_mem_write_in =
        control_mux_select ? 1'b0 : mem_write;

    assign id_ex_mem_to_reg_in =
        control_mux_select ? 1'b0 : mem_to_reg;

    assign id_ex_alu_src_in =
        control_mux_select ? 1'b0 : alu_src;

    assign id_ex_branch_in =
        control_mux_select ? 1'b0 : branch;

    assign id_ex_jump_in =
        control_mux_select ? 1'b0 : jump;

    assign id_ex_jalr_in =
        control_mux_select ? 1'b0 : jalr;

        assign id_ex_lui_in =
    control_mux_select ? 1'b0 : lui;

assign id_ex_auipc_in =
    control_mux_select ? 1'b0 : auipc;

    assign id_ex_alu_op_in =
        control_mux_select ? 2'b00 : alu_op;


    // ============================================================
    // ID/EX
    // ============================================================

    wire [31:0] ex_pc;
    wire [31:0] ex_read_data1;
    wire [31:0] ex_read_data2;
    wire [31:0] ex_immediate;

    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
     

    wire [2:0] ex_func3;
    wire [6:0] ex_func7;

    wire ex_reg_write;
    wire ex_mem_write;
    wire ex_mem_to_reg;
    wire ex_alu_src;
    wire ex_branch;
    wire ex_jump;
    wire ex_jalr;
    wire ex_lui;
wire ex_auipc;

    wire [1:0] ex_alu_op;


    pipeline_id_ex id_ex (
        .clk(clk),
        .rst(rst),
        .flush(flush_id_ex),

        .pc_in(id_pc),

        .read_data1_in(read_data1),
        .read_data2_in(read_data2),
        .immediate_in(immediate),

        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),

        .func3_in(func3),
        .func7_in(func7),

        .reg_write_in(id_ex_reg_write_in),
        .mem_read_in(id_ex_mem_read_in),
        .mem_write_in(id_ex_mem_write_in),
        .mem_to_reg_in(id_ex_mem_to_reg_in),
        .alu_src_in(id_ex_alu_src_in),
        .branch_in(id_ex_branch_in),
        .jump_in(id_ex_jump_in),
        .jalr_in(id_ex_jalr_in),

        .alu_op_in(id_ex_alu_op_in),
        .lui_in(id_ex_lui_in),
.auipc_in(id_ex_auipc_in),

        .pc_out(ex_pc),

        .read_data1_out(ex_read_data1),
        .read_data2_out(ex_read_data2),
        .immediate_out(ex_immediate),

        .rs1_out(ex_rs1),
        .rs2_out(ex_rs2),
        .rd_out(ex_rd),

        .func3_out(ex_func3),
        .func7_out(ex_func7),

        .reg_write_out(ex_reg_write),
        .mem_read_out(ex_mem_read),
        .mem_write_out(ex_mem_write),
        .mem_to_reg_out(ex_mem_to_reg),
        .alu_src_out(ex_alu_src),
        .branch_out(ex_branch),
        .jump_out(ex_jump),
        .jalr_out(ex_jalr),
        .lui_out(ex_lui),
.auipc_out(ex_auipc),

        .alu_op_out(ex_alu_op)
    );


    // ============================================================
    // ALU CONTROL
    // ============================================================

    wire [3:0] alu_operation;


    alu_control alu_ctrl (
        .alu_op(ex_alu_op),
        .func3(ex_func3),
        .func7(ex_func7),

        .alu_control(alu_operation)
    );


    // ============================================================
    // FORWARDING
    // ============================================================

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    wire [4:0] mem_rd;
    wire mem_reg_write;

    wire [31:0] mem_alu_result;


    forwarding_unit forwarding (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),

        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),

        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );


    wire [31:0] forwarded_a;
    wire [31:0] forwarded_b;


    forwarding_mux mux_forward_a (
        .original_value(ex_read_data1),
        .mem_value(mem_alu_result),
        .wb_value(write_back_data),

        .select(forward_a),

        .result(forwarded_a)
    );


    forwarding_mux mux_forward_b (
        .original_value(ex_read_data2),
        .mem_value(mem_alu_result),
        .wb_value(write_back_data),

        .select(forward_b),

        .result(forwarded_b)
    );


    // ============================================================
    // BRANCH UNIT
    // ============================================================

    branch_unit branch_logic (
        .rs1_value(forwarded_a),
        .rs2_value(forwarded_b),

        .pc(ex_pc),
        .immediate(ex_immediate),

        .branch(ex_branch),
        .jump(1'b0),

        .func3(ex_func3),

        .branch_taken(branch_taken),
        .target_address(branch_target)
    );


    // ============================================================
    // JUMP UNIT
    // ============================================================

    jump_unit jump_logic (
        .pc(ex_pc),

        .rs1_value(forwarded_a),
        .immediate(ex_immediate),

        .jump(ex_jump),
        .jalr(ex_jalr),

        .target_address(jump_target),
        .jump_taken(jump_taken)
    );


    // ============================================================
    // LINK ADDRESS
    // ============================================================

    wire [31:0] link_address;


    jump_link_unit link_unit (
        .pc(ex_pc),
        .jump(ex_jump),
        .link_address(link_address)
    );


    // ============================================================
// ALU
// ============================================================

wire [31:0] alu_input_a;
wire [31:0] alu_input_b;
wire [31:0] alu_result;

// Select ALU input A
// LUI   : 0 + immediate
// AUIPC : PC + immediate
// Others: normal forwarded register value
assign alu_input_a =
    ex_lui   ? 32'b0 :
    ex_auipc ? ex_pc :
               forwarded_a;

mux2_1_32bit alu_mux (
    .a(forwarded_b),
    .b(ex_immediate),

    .sel(ex_alu_src),

    .y(alu_input_b)
);

alu processor_alu (
    .a(alu_input_a),
    .b(alu_input_b),

    .op(alu_operation),

    .y(alu_result)
);

    // ============================================================
    // EX/MEM
    // ============================================================

    wire [31:0] mem_read_data2;
    wire [31:0] mem_link_address;

    wire mem_mem_read;
    wire mem_mem_write;
    wire mem_mem_to_reg;
    wire mem_jump;


    pipeline_ex_mem ex_mem (
        .clk(clk),
        .rst(rst),

        .alu_result_in(alu_result),
        .read_data2_in(forwarded_b),
        .link_address_in(link_address),

        .rd_in(ex_rd),

        .reg_write_in(ex_reg_write),
        .mem_read_in(ex_mem_read),
        .mem_write_in(ex_mem_write),
        .mem_to_reg_in(ex_mem_to_reg),
        .jump_in(ex_jump),

        .alu_result_out(mem_alu_result),
        .read_data2_out(mem_read_data2),
        .link_address_out(mem_link_address),

        .rd_out(mem_rd),

        .reg_write_out(mem_reg_write),
        .mem_read_out(mem_mem_read),
        .mem_write_out(mem_mem_write),
        .mem_to_reg_out(mem_mem_to_reg),
        .jump_out(mem_jump)
    );


    // ============================================================
    // DATA MEMORY
    // ============================================================

    wire [31:0] memory_data;


    data_memory dmem (
        .clk(clk),

        .mem_read(mem_mem_read),
        .mem_write(mem_mem_write),

        .address(mem_alu_result),

        .write_data(mem_read_data2),

        .read_data(memory_data)
    );


    // ============================================================
    // MEM/WB
    // ============================================================

    wire [31:0] wb_alu_result;
    wire [31:0] wb_memory_data;
    wire [31:0] wb_link_address;

    wire wb_mem_to_reg;
    wire wb_jump;


    pipeline_mem_wb mem_wb (
        .clk(clk),
        .rst(rst),

        .alu_result_in(mem_alu_result),
        .memory_data_in(memory_data),
        .link_address_in(mem_link_address),

        .rd_in(mem_rd),

        .reg_write_in(mem_reg_write),
        .mem_to_reg_in(mem_mem_to_reg),
        .jump_in(mem_jump),

        .alu_result_out(wb_alu_result),
        .memory_data_out(wb_memory_data),
        .link_address_out(wb_link_address),

        .rd_out(wb_rd),

        .reg_write_out(wb_reg_write),
        .mem_to_reg_out(wb_mem_to_reg),
        .jump_out(wb_jump)
    );


    // ============================================================
    // WRITEBACK
    // ============================================================

    writeback_mux wb_mux (
        .alu_result(wb_alu_result),
        .memory_data(wb_memory_data),
        .link_address(wb_link_address),

        .mem_to_reg(wb_mem_to_reg),
        .jump(wb_jump),

        .writeback_data(write_back_data)
    );

endmodule