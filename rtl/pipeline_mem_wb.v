module pipeline_mem_wb (
    input clk,
    input rst,

    input [31:0] alu_result_in,
    input [31:0] memory_data_in,
    input [31:0] link_address_in,

    input [4:0] rd_in,

    input reg_write_in,
    input mem_to_reg_in,
    input jump_in,

    output reg [31:0] alu_result_out,
    output reg [31:0] memory_data_out,
    output reg [31:0] link_address_out,

    output reg [4:0] rd_out,

    output reg reg_write_out,
    output reg mem_to_reg_out,
    output reg jump_out
);

always @(posedge clk) begin

    if (rst) begin

        alu_result_out   <= 32'b0;
        memory_data_out  <= 32'b0;
        link_address_out <= 32'b0;

        rd_out           <= 5'b0;

        reg_write_out    <= 1'b0;
        mem_to_reg_out   <= 1'b0;
        jump_out         <= 1'b0;

    end
    else begin

        alu_result_out   <= alu_result_in;
        memory_data_out  <= memory_data_in;
        link_address_out <= link_address_in;

        rd_out           <= rd_in;

        reg_write_out    <= reg_write_in;
        mem_to_reg_out   <= mem_to_reg_in;
        jump_out         <= jump_in;

    end

end

endmodule