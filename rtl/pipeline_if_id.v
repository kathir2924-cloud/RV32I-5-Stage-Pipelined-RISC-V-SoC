module pipeline_if_id (

    input        clk,
    input        rst,
    input        enable,
    input        flush,

    input        [31:0] pc_in,
    input        [31:0] instruction_in,
    input               valid_in,

    output reg   [31:0] pc_out,
    output reg   [31:0] instruction_out,
    output reg          valid_out

);

always @(posedge clk) begin

    if (rst) begin
        pc_out          <= 32'b0;
        instruction_out <= 32'b0;
        valid_out       <= 1'b0;
    end

    else if (flush) begin
        pc_out          <= 32'b0;
        instruction_out <= 32'b0;
        valid_out       <= 1'b0;
    end

    else if (enable) begin
        pc_out          <= pc_in;
        instruction_out <= instruction_in;
        valid_out       <= valid_in;
    end

end

endmodule