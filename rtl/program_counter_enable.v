module program_counter_enable (
    input        clk,
    input        rst,
    input        enable,
    input [31:0] next_pc,
    output reg [31:0] pc
);

always @(posedge clk) begin
    if (rst) begin
        pc <= 32'b0;
    end
    else if (enable) begin
        pc <= next_pc;
    end
end

endmodule