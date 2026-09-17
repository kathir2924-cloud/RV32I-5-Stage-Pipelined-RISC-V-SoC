module pc_next_logic (
    input  [31:0] pc,
    input  [31:0] target_address,
    input         control_transfer,
    output [31:0] next_pc
);

assign next_pc = control_transfer ? target_address : (pc + 32'd4);

endmodule