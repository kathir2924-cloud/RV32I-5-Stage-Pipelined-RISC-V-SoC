module pipeline_id_ex (
    input clk,
    input rst,
    input flush,

    input [31:0] pc_in,
    input [31:0] read_data1_in,
    input [31:0] read_data2_in,
    input [31:0] immediate_in,

    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,

    input [2:0] func3_in,
    input [6:0] func7_in,

    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input alu_src_in,
    input branch_in,
    input jump_in,
    input jalr_in,
    input lui_in,
input auipc_in,

    input [1:0] alu_op_in,

    output reg [31:0] pc_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    output reg [2:0] func3_out,
    output reg [6:0] func7_out,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg alu_src_out,
    output reg branch_out,
    output reg jump_out,
    output reg jalr_out,
    output reg lui_out,
output reg auipc_out,

    output reg [1:0] alu_op_out
);

always @(posedge clk) begin

    if (rst) begin

        pc_out         <= 32'b0;
        read_data1_out <= 32'b0;
        read_data2_out <= 32'b0;
        immediate_out  <= 32'b0;

        rs1_out        <= 5'b0;
        rs2_out        <= 5'b0;
        rd_out         <= 5'b0;

        func3_out      <= 3'b0;
        func7_out      <= 7'b0;

        reg_write_out  <= 1'b0;
        mem_read_out   <= 1'b0;
        mem_write_out  <= 1'b0;
        mem_to_reg_out <= 1'b0;
        alu_src_out    <= 1'b0;
        branch_out     <= 1'b0;
        jump_out       <= 1'b0;
        jalr_out       <= 1'b0;
        lui_out   <= 1'b0;
auipc_out <= 1'b0;

        alu_op_out     <= 2'b00;

    end

    else if (flush) begin

        pc_out         <= 32'b0;
        read_data1_out <= 32'b0;
        read_data2_out <= 32'b0;
        immediate_out  <= 32'b0;

        rs1_out        <= 5'b0;
        rs2_out        <= 5'b0;
        rd_out         <= 5'b0;

        func3_out      <= 3'b0;
        func7_out      <= 7'b0;

        reg_write_out  <= 1'b0;
        mem_read_out   <= 1'b0;
        mem_write_out  <= 1'b0;
        mem_to_reg_out <= 1'b0;
        alu_src_out    <= 1'b0;
        branch_out     <= 1'b0;
        jump_out       <= 1'b0;
        jalr_out       <= 1'b0;
        lui_out   <= 1'b0;
auipc_out <= 1'b0;

        alu_op_out     <= 2'b00;

    end

    else begin

        pc_out         <= pc_in;
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        immediate_out  <= immediate_in;

        rs1_out        <= rs1_in;
        rs2_out        <= rs2_in;
        rd_out         <= rd_in;

        func3_out      <= func3_in;
        func7_out      <= func7_in;

        reg_write_out  <= reg_write_in;
        mem_read_out   <= mem_read_in;
        mem_write_out  <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        alu_src_out    <= alu_src_in;
        branch_out     <= branch_in;
        jump_out       <= jump_in;
        jalr_out       <= jalr_in;
        lui_out   <= lui_in;
auipc_out <= auipc_in;

        alu_op_out     <= alu_op_in;

    end

end

endmodule