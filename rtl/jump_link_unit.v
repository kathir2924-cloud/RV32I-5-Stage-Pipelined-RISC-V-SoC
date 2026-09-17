module jump_link_unit (
    input  [31:0] pc,
    input         jump,
    output [31:0] link_address
);

assign link_address = jump ? (pc + 32'd4) : 32'b0;

endmodule