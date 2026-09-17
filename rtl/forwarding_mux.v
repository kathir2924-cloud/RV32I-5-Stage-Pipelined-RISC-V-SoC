module forwarding_mux (
    input  [31:0] original_value,
    input  [31:0] mem_value,
    input  [31:0] wb_value,
    input  [1:0]  select,
    output reg [31:0] result
);

always @(*) begin
    case (select)
        2'b00: result = original_value;
        2'b10: result = mem_value;
        2'b01: result = wb_value;
        default: result = original_value;
    endcase
end

endmodule