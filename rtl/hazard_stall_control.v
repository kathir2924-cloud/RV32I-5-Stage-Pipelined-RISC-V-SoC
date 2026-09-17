module hazard_stall_control (
    input  stall,

    output reg pc_write,
    output reg if_id_write,
    output reg control_mux_select
);

always @(*) begin

    if (stall) begin
        // Freeze PC
        pc_write = 1'b0;

        // Freeze IF/ID
        if_id_write = 1'b0;

        // Insert bubble into ID/EX
        control_mux_select = 1'b1;
    end
    else begin
        // Normal operation
        pc_write = 1'b1;
        if_id_write = 1'b1;
        control_mux_select = 1'b0;
    end

end

endmodule