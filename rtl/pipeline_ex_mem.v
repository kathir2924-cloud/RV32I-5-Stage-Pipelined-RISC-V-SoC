module pipeline_ex_mem (
    input clk,
    input rst,

    // Valid bit
    input valid_in,

    input [31:0] alu_result_in,
    input [31:0] read_data2_in,
    input [31:0] link_address_in,

    input [4:0] rd_in,

    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input jump_in,

    // Valid bit
    output reg valid_out,

    output reg [31:0] alu_result_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] link_address_out,

    output reg [4:0] rd_out,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg jump_out
);

always @(posedge clk) begin

    // --------------------------------------------------
    // RESET
    // --------------------------------------------------
    if (rst) begin

        valid_out        <= 1'b0;

        alu_result_out   <= 32'b0;
        read_data2_out   <= 32'b0;
        link_address_out <= 32'b0;

        rd_out           <= 5'b0;

        reg_write_out    <= 1'b0;
        mem_read_out     <= 1'b0;
        mem_write_out    <= 1'b0;
        mem_to_reg_out   <= 1'b0;
        jump_out         <= 1'b0;

    end

    // --------------------------------------------------
    // NORMAL PIPELINE TRANSFER
    // --------------------------------------------------
    else begin

        valid_out        <= valid_in;

        alu_result_out   <= alu_result_in;
        read_data2_out   <= read_data2_in;
        link_address_out <= link_address_in;

        rd_out           <= rd_in;

        reg_write_out    <= reg_write_in;
        mem_read_out     <= mem_read_in;
        mem_write_out    <= mem_write_in;
        mem_to_reg_out   <= mem_to_reg_in;
        jump_out         <= jump_in;

    end

end

endmodule