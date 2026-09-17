module pipeline_if_id_enable (
    input        clk,
    input        rst,
    input        enable,

    input  [31:0] pc_in,
    input  [31:0] instruction_in,

    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);

always @(posedge clk) begin

    if (rst) begin
        pc_out          <= 32'b0;
        instruction_out <= 32'b0;
    end
    else if (enable) begin
        pc_out          <= pc_in;
        instruction_out <= instruction_in;
    end

end

endmodule