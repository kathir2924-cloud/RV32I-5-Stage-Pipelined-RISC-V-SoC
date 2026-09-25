module performance_counters (
    input clk,
    input rst,

    // One cycle pulse when an instruction completes WB
    input instruction_retired,

    // One cycle pulse when the pipeline is stalled
    input stall,

    // Counter outputs
    output reg [63:0] cycle_count,
    output reg [63:0] instret_count,
    output reg [63:0] stall_count
);

always @(posedge clk) begin

    if (rst) begin

        cycle_count  <= 64'd0;
        instret_count <= 64'd0;
        stall_count  <= 64'd0;

    end
    else begin

        // Count every active CPU cycle
        cycle_count <= cycle_count + 64'd1;

        // Count instructions reaching retirement
        if (instruction_retired)
            instret_count <= instret_count + 64'd1;

        // Count cycles where the pipeline is stalled
        if (stall)
            stall_count <= stall_count + 64'd1;

    end

end

endmodule