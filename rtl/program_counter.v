module program_counter(
    input clk,
    input rst,
    output reg [31:0]pc
);
always@(posedge clk) begin
    if(rst==1) begin
        pc<=32'b0;
    end
    else begin
        pc<=pc+4;
    end
end
endmodule
    
