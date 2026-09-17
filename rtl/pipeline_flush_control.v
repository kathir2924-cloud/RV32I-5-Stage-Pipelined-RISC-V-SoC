module pipeline_flush_control (
    input  control_transfer,
    output reg flush_if_id,
    output reg flush_id_ex
);

always @(*) begin
    flush_if_id = 1'b0;
    flush_id_ex = 1'b0;

    if (control_transfer) begin
        flush_if_id = 1'b1;
        flush_id_ex = 1'b1;
    end
end

endmodule