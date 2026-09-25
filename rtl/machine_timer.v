module machine_timer #(
    parameter TIMER_LIMIT = 32'd20
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    output reg         timer_interrupt
);

    reg [31:0] counter;

    always @(posedge clk) begin

        if (rst) begin

            counter         <= 32'd0;
            timer_interrupt <= 1'b0;

        end

        else if (!enable) begin

            counter         <= 32'd0;
            timer_interrupt <= 1'b0;

        end

        else if (counter >= TIMER_LIMIT - 1) begin

            counter         <= counter;
            timer_interrupt <= 1'b1;

        end

        else begin

            counter         <= counter + 32'd1;
            timer_interrupt <= 1'b0;

        end

    end

endmodule