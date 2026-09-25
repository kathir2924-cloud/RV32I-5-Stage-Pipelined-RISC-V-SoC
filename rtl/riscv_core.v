`timescale 1ns/1ps

module riscv_core #(
    parameter CSR_TEST               = 1'b0,
    parameter TRAP_TEST              = 1'b0,
    parameter TIMER_TEST             = 1'b0,
    parameter MMIO_TEST              = 1'b0,
    parameter UART_TX_TEST           = 1'b0,
    parameter UART_RX_TEST           = 1'b0,
    parameter UART_RX_INTERRUPT_TEST = 1'b0
) (
    input wire clk,
    input wire rst,
    input wire uart_rx
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
    wire trap_taken;
wire mret_taken;
wire timer_interrupt;
wire timer_interrupt_pending;

wire uart_rx_interrupt_pending;

wire interrupt_taken;

wire [31:0] interrupt_cause;
wire [31:0] effective_trap_cause;
wire [31:0] trap_target;
wire [31:0] mret_target;

wire [31:0] selected_target;

assign interrupt_taken =
    (timer_interrupt_pending ||
     uart_rx_interrupt_pending) &&
    !trap_taken &&
    !mret_taken &&
    (pc != 32'h00000000);

assign interrupt_cause =
    uart_rx_interrupt_pending
        ? 32'h8000000B
        : 32'h80000007;

assign effective_trap_cause =
    interrupt_taken
        ? interrupt_cause
        : ex_trap_cause;

assign trap_taken =
    ex_valid &&
    ex_trap_enter;

assign mret_taken =
    ex_valid &&
    ex_mret;

assign control_transfer =
    trap_taken |
    interrupt_taken |
    mret_taken |
    branch_taken |
    jump_taken;

assign trap_target = mtvec_value;

assign mret_target = mepc_value;

assign selected_target =
    trap_taken
        ? trap_target
        : interrupt_taken
            ? trap_target
            : mret_taken
                ? mret_target
                : jump_taken
                    ? jump_target
                    : branch_target;

assign pc_write_final =
    control_transfer
        ? 1'b1
        : pc_write;


    // ============================================================
    // PC
    // ============================================================

    pc_next_logic pc_logic (
        .pc(pc),
        .target_address(selected_target),
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
//
// CSR_TEST = 0
//     -> normal processor program
//
// CSR_TEST = 1
//     -> dedicated CSR verification program
// ============================================================

generate

    if (CSR_TEST == 1'b1) begin : GEN_CSR_TEST_IMEM

        csr_test_instruction_memory csr_test_imem (
            .address(pc),
            .instruction(instruction)
        );

    end

    else if (TIMER_TEST == 1'b1) begin : GEN_TIMER_TEST_IMEM

        timer_interrupt_instruction_memory timer_test_imem (
            .address(pc),
            .instruction(instruction)
        );

    end

    else if (MMIO_TEST == 1'b1) begin : GEN_MMIO_TEST_IMEM

        mmio_test_instruction_memory mmio_test_imem (
            .address(pc),
            .instruction(instruction)
        );

    end

    else if (UART_TX_TEST == 1'b1) begin : GEN_UART_TX_TEST_IMEM

        mmio_uart_tx_test_instruction_memory uart_tx_test_imem (
            .address(pc),
            .instruction(instruction)
        );

    end

    else if (UART_RX_INTERRUPT_TEST == 1'b1) begin : GEN_UART_RX_INTERRUPT_TEST_IMEM

        uart_rx_interrupt_test_instruction_memory uart_rx_interrupt_test_imem (
            .address(pc),
            .instruction(instruction)
        );

    end

    else if (UART_RX_TEST == 1'b1) begin : GEN_UART_RX_TEST_IMEM

        mmio_uart_rx_test_instruction_memory uart_rx_test_imem (
            .address(pc),
            .instruction(instruction)
        );

    end

    else begin : GEN_TRAP_TEST_IMEM

        trap_test_instruction_memory trap_test_imem (
            .address(pc),
            .instruction(instruction)
        );

    end

endgenerate 


    // ============================================================
    // IF/ID
    // ============================================================

    wire [31:0] id_pc;
    wire [31:0] id_instruction;

    wire if_id_write;

    wire flush_if_id;
    wire flush_id_ex;
    wire if_id_valid_in;
wire id_valid;

assign if_id_valid_in = 1'b1;
wire normal_flush_if_id;
wire normal_flush_id_ex;


    pipeline_flush_control flush_control (
    .control_transfer(branch_taken | jump_taken),
    .flush_if_id(normal_flush_if_id),
    .flush_id_ex(normal_flush_id_ex)
);
assign flush_if_id =
    normal_flush_if_id |
    trap_taken |
    interrupt_taken |
    mret_taken;

assign flush_id_ex =
    normal_flush_id_ex |
    trap_taken |
    interrupt_taken |
    mret_taken;
    pipeline_if_id if_id (
    .clk(clk),
    .rst(rst),
    .enable(if_id_write),
    .flush(flush_if_id),

    .pc_in(pc),
    .instruction_in(instruction),
    .valid_in(if_id_valid_in),

    .pc_out(id_pc),
    .instruction_out(id_instruction),
    .valid_out(id_valid)
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
    

    mmio_gpio gpio (
    .clk(clk),
    .rst(rst),

    .write_enable(mmio_write && gpio_sel),
    .read_enable(mmio_read && gpio_sel),

    .write_data(mem_read_data2),

    .read_data(gpio_read_data),

    .gpio_out(gpio_out)
);

mmio_uart_tx #(
    .CLKS_PER_BIT(4)
) uart_tx_peripheral (
    .clk(clk),
    .rst(rst),
    .write_enable(mmio_write && uart_tx_sel),
    .write_data(mem_read_data2),
    .tx(uart_tx),
    .busy(uart_tx_busy)
);

mmio_uart_rx #(
    .CLKS_PER_BIT(4)
) uart_rx_peripheral (
    .clk(clk),
    .rst(rst),
    .rx(uart_rx),
    .read_enable(mmio_read && uart_rx_sel),
    .read_data(uart_rx_read_data),
    .data_valid(uart_rx_data_valid),
    .receiving_status(uart_rx_receiving)
);
assign status_read_data = {
    29'b0,
    uart_rx_receiving,
    uart_rx_data_valid,
    uart_tx_busy
};
    // ============================================================
// CSR DECODER SIGNALS
// ============================================================

wire        csr_read;
wire        csr_write;
wire [11:0] csr_addr;
wire [2:0]  csr_op;
wire [4:0]  csr_imm;
wire        csr_use_imm;


    instruction_decoder decoder (
    .instruction(id_instruction),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),

    .opcode(opcode),
    .func3(func3),
    .func7(func7),

    .alu_op(decoder_alu_op),
    .imm_type(imm_type),

    .csr_read(csr_read),
    .csr_write(csr_write),
    .csr_addr(csr_addr),
    .csr_op(csr_op),
    .csr_imm(csr_imm),
    .csr_use_imm(csr_use_imm)
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

wire csr_read_control;
wire csr_write_control;

    wire [1:0] alu_op;
    wire trap_enter;
wire mret;
wire [31:0] trap_cause;


    control_unit control (
    .opcode(opcode),
    .func3(func3),
    .func7(func7),
    
    .instruction(id_instruction),

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

    .csr_read(csr_read_control),
    .csr_write(csr_write_control),

    .trap_enter(trap_enter),
    .mret(mret),
    .trap_cause(trap_cause),

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

    // ============================================================
// CSR ID/EX INPUT SIGNALS
// ============================================================

wire        id_ex_csr_read_in;
wire        id_ex_csr_write_in;
wire [11:0] id_ex_csr_addr_in;
wire [2:0]  id_ex_csr_op_in;
wire [4:0]  id_ex_csr_imm_in;
wire        id_ex_csr_use_imm_in;
wire        id_ex_trap_enter_in;
wire        id_ex_mret_in;
wire [31:0] id_ex_trap_cause_in;
assign id_ex_trap_enter_in =
    control_mux_select ? 1'b0 :
    id_valid ? trap_enter : 1'b0;

assign id_ex_mret_in =
    control_mux_select ? 1'b0 :
    id_valid ? mret : 1'b0;

assign id_ex_trap_cause_in =
    id_valid ? trap_cause : 32'b0;

assign id_ex_csr_read_in =
    control_mux_select ? 1'b0 : csr_read;

assign id_ex_csr_write_in =
    control_mux_select ? 1'b0 : csr_write;

assign id_ex_csr_addr_in =
    csr_addr;

assign id_ex_csr_op_in =
    csr_op;

assign id_ex_csr_imm_in =
    csr_imm;

assign id_ex_csr_use_imm_in =
    csr_use_imm;


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
    wire id_ex_valid_in;
wire ex_valid;
wire        ex_csr_read;
wire        ex_csr_write;
wire [11:0] ex_csr_addr;
wire [2:0]  ex_csr_op;
wire [4:0]  ex_csr_imm;

wire        ex_trap_enter;
wire        ex_mret;
wire [31:0] ex_trap_cause;
// ============================================================
// CSR EXECUTION SIGNALS
// ============================================================

wire [31:0] csr_rdata;
wire [31:0] csr_operand;
wire [31:0] csr_wdata;

wire        csr_write_enable;

wire [31:0] ex_result_to_mem;

assign id_ex_valid_in = id_valid;
wire [31:0] ex_instruction;


    pipeline_id_ex id_ex (
        .clk(clk),
        .rst(rst),
        .flush(flush_id_ex),
        .valid_in(id_ex_valid_in),
        .csr_read_in(id_ex_csr_read_in),
.csr_write_in(id_ex_csr_write_in),
.csr_addr_in(id_ex_csr_addr_in),
.csr_op_in(id_ex_csr_op_in),
.csr_imm_in(id_ex_csr_imm_in),
.csr_use_imm_in(id_ex_csr_use_imm_in),
.trap_enter_in(id_ex_trap_enter_in),
.mret_in(id_ex_mret_in),
.trap_cause_in(id_ex_trap_cause_in),

        .pc_in(id_pc),

        .read_data1_in(read_data1),
        .read_data2_in(read_data2),
        .immediate_in(immediate),

        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .instruction_in(id_instruction),

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
.valid_out(ex_valid),
.csr_read_out(ex_csr_read),
.csr_write_out(ex_csr_write),
.csr_addr_out(ex_csr_addr),
.csr_op_out(ex_csr_op),
.csr_imm_out(ex_csr_imm),
.csr_use_imm_out(ex_csr_use_imm),
.instruction_out(ex_instruction),

.trap_enter_out(ex_trap_enter),
.mret_out(ex_mret),
.trap_cause_out(ex_trap_cause),

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
// CSR EXECUTION
// ============================================================

// For register CSR instructions:
//
// CSRRW  -> rs1
// CSRRS  -> rs1
// CSRRC  -> rs1
//
// For immediate CSR instructions:
//
// CSRRWI -> zimm
// CSRRSI -> zimm
// CSRRCI -> zimm

assign csr_operand =
    ex_csr_use_imm
    ? {27'b0, ex_csr_imm}
    : forwarded_a;


// ============================================================
// CSR NEW VALUE CALCULATION
// ============================================================

reg [31:0] csr_wdata_reg;

always @(*) begin

    case (ex_csr_op)

        // -----------------------------------------------------
        // CSRRW / CSRRWI
        // new CSR = source
        // -----------------------------------------------------

        3'b001,
        3'b101:
            csr_wdata_reg = csr_operand;


        // -----------------------------------------------------
        // CSRRS / CSRRSI
        // new CSR = old CSR OR source
        // -----------------------------------------------------

        3'b010,
        3'b110:
            csr_wdata_reg = csr_rdata | csr_operand;


        // -----------------------------------------------------
        // CSRRC / CSRRCI
        // new CSR = old CSR AND NOT source
        // -----------------------------------------------------

        3'b011,
        3'b111:
            csr_wdata_reg = csr_rdata & ~csr_operand;


        default:
            csr_wdata_reg = 32'b0;

    endcase

end

assign csr_wdata = csr_wdata_reg;


// ============================================================
// CSR WRITE ENABLE
// ============================================================
//
// CSRRW / CSRRWI:
//     Always write.
//
// CSRRS / CSRRC:
//     Write only when rs1 != x0.
//
// CSRRSI / CSRRCI:
//     Write only when zimm != 0.
//
// ============================================================

assign csr_write_enable =
    ex_valid &&
    ex_csr_write &&
    (
        (ex_csr_op == 3'b001) ||       // CSRRW
        (ex_csr_op == 3'b101) ||       // CSRRWI

        ((ex_csr_op == 3'b010) &&
         (ex_rs1 != 5'd0)) ||          // CSRRS

        ((ex_csr_op == 3'b011) &&
         (ex_rs1 != 5'd0)) ||          // CSRRC

        ((ex_csr_op == 3'b110) &&
         (ex_csr_imm != 5'd0)) ||      // CSRRSI

        ((ex_csr_op == 3'b111) &&
         (ex_csr_imm != 5'd0))         // CSRRCI
    );

   // ============================================================



// ============================================================
// MACHINE TIMER
// ============================================================



machine_timer #(
    .TIMER_LIMIT(20)
) timer_unit (
    .clk(clk),
    .rst(rst),
    .enable(1'b1),
    .timer_interrupt(timer_interrupt)
);


// ============================================================
// CSR REGISTER FILE
// ============================================================

wire [31:0] mtvec_value;
wire [31:0] mepc_value;
wire [31:0] interrupt_pc;

assign interrupt_pc = pc;

riscv_csr csr_unit (
    .clk(clk),
    .rst(rst),

    .csr_addr(ex_csr_addr),
    .csr_rdata(csr_rdata),

    .csr_write(csr_write_enable),
    .csr_wdata(csr_wdata),

    .trap_enter(
        (ex_valid && ex_trap_enter) ||
        interrupt_taken
    ),

    .trap_pc(
        interrupt_taken
            ? pc
            : ex_pc
    ),

    .trap_cause(
        interrupt_taken
            ? interrupt_cause
            : ex_trap_cause
    ),

    .trap_value(
        (ex_trap_cause == 32'd2)
            ? ex_instruction
            : 32'b0
    ),

    .mret(ex_valid && ex_mret),

    .mtvec_value(mtvec_value),
    .mepc_value(mepc_value),

    .timer_interrupt(timer_interrupt),
    .timer_interrupt_pending(timer_interrupt_pending),

    .uart_rx_interrupt(uart_rx_interrupt),
    .uart_rx_interrupt_pending(uart_rx_interrupt_pending),

    .cycle_count(cycle_count),
    .instret_count(instret_count)
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
    wire mem_valid;
    // ============================================================
// RESULT SENT TO EX/MEM
// ============================================================
//
// Normal instruction:
//     ALU result
//
// CSR instruction:
//     old CSR value
//
// The old CSR value is what must be written to rd.
// ============================================================

assign ex_result_to_mem =
    ex_csr_read
    ? csr_rdata
    : alu_result;


    pipeline_ex_mem ex_mem (
    .clk(clk),
    .rst(rst),
    .valid_in(ex_valid),

    .alu_result_in(ex_result_to_mem),
    .read_data2_in(forwarded_b),
    .link_address_in(link_address),

    .rd_in(ex_rd),

    .reg_write_in(ex_reg_write),
    .mem_read_in(ex_mem_read),
    .mem_write_in(ex_mem_write),
    .mem_to_reg_in(ex_mem_to_reg),
    .jump_in(ex_jump),

    .valid_out(mem_valid),

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
// MMIO
// ============================================================

wire        gpio_sel;
wire        uart_tx_sel;
wire        uart_rx_sel;

wire        mmio_read;
wire        mmio_write;
wire        uart_tx;
wire        uart_tx_busy;

wire [31:0] uart_rx_read_data;
wire        uart_rx_data_valid;
wire [31:0] mmio_read_data;
wire [31:0] gpio_read_data;

wire [31:0] gpio_out;
wire status_sel;
wire [31:0] status_read_data;
wire uart_rx_receiving;
wire control_sel;
reg uart_rx_interrupt_enable;
wire uart_rx_interrupt;

reg uart_rx_interrupt_pending_latched;
wire uart_rx_interrupt_clear;






mmio_decoder mmio (
    .mem_read(mem_mem_read),
    .mem_write(mem_mem_write),

    .address(mem_alu_result),
    .write_data(mem_read_data2),

    .read_data(mmio_read_data),

    .gpio_sel(gpio_sel),
    .uart_tx_sel(uart_tx_sel),
    .uart_rx_sel(uart_rx_sel),

    .mmio_read(mmio_read),
    .mmio_write(mmio_write),
    .status_sel(status_sel),
    .control_sel(control_sel)
);

// ============================================================
// UART RX INTERRUPT ENABLE
// CONTROL register bit 0
// ============================================================

always @(posedge clk) begin

    if (rst) begin
        uart_rx_interrupt_enable <= 1'b0;
    end

    else if (mmio_write && control_sel) begin
        uart_rx_interrupt_enable <= mem_read_data2[0];
    end

end

assign uart_rx_interrupt =
    uart_rx_interrupt_enable &&
    uart_rx_interrupt_pending_latched;
always @(posedge clk) begin
    if (rst) begin
        uart_rx_interrupt_pending_latched <= 1'b0;
    end
    else begin
        // A new UART byte has arrived
        if (uart_rx_data_valid) begin
            uart_rx_interrupt_pending_latched <= 1'b1;
        end

        // CPU reads UART RX data -> acknowledge/clear interrupt
        else if (uart_rx_interrupt_clear) begin
            uart_rx_interrupt_pending_latched <= 1'b0;
        end
    end
end
assign uart_rx_interrupt_clear =
    mmio_read &&
    uart_rx_sel;


    // ============================================================
    // DATA MEMORY
    // ============================================================

    wire [31:0] memory_data;


    data_memory dmem (
    .clk(clk),

    .mem_read(mem_mem_read && !mmio_read),
    .mem_write(mem_mem_write && !mmio_write),

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
    wire wb_valid;


    pipeline_mem_wb mem_wb (
        .clk(clk),
        .rst(rst),
        .valid_in(mem_valid),   

        .alu_result_in(mem_alu_result),
        .memory_data_in(
    gpio_sel
        ? gpio_read_data
        : uart_rx_sel
            ? uart_rx_read_data
            : status_sel
                ? status_read_data
                : memory_data
),
        .link_address_in(mem_link_address),

        .rd_in(mem_rd),

        .reg_write_in(mem_reg_write),
        .mem_to_reg_in(mem_mem_to_reg),
        .jump_in(mem_jump),

        .valid_out(wb_valid),
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


    // ============================================================
// PERFORMANCE COUNTERS
// ============================================================

wire instruction_retired;

wire [63:0] cycle_count;
wire [63:0] instret_count;
wire [63:0] stall_count;

// An instruction retires when a valid instruction reaches WB.
assign instruction_retired = wb_valid;

performance_counters perf_counters (
    .clk(clk),
    .rst(rst),

    .instruction_retired(instruction_retired),
    .stall(stall),

    .cycle_count(cycle_count),
    .instret_count(instret_count),
    .stall_count(stall_count)
);

endmodule