`timescale 1ns/1ps

module hazard_stall_control_tb;

reg stall;

wire pc_write;
wire if_id_write;
wire control_mux_select;

hazard_stall_control dut (
    .stall(stall),
    .pc_write(pc_write),
    .if_id_write(if_id_write),
    .control_mux_select(control_mux_select)
);

initial begin

    // Normal operation
    stall = 1'b0;
    #10;

    // Stall condition
    stall = 1'b1;
    #10;

    // Back to normal
    stall = 1'b0;
    #10;

    $finish;

end

initial begin

    $monitor(
        "Time=%0t | Stall=%b | PC_Write=%b | IF_ID_Write=%b | Control_Mux=%b",
        $time,
        stall,
        pc_write,
        if_id_write,
        control_mux_select
    );

end

initial begin

    $dumpfile("hazard_stall_control.vcd");
    $dumpvars(0, hazard_stall_control_tb);

end

endmodule