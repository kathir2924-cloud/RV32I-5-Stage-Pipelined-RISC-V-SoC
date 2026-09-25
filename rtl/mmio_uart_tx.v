`timescale 1ns/1ps

module mmio_uart_tx #(
    parameter CLKS_PER_BIT = 4
)(
    input  wire        clk,
    input  wire        rst,

    // MMIO interface
    input  wire        write_enable,
    input  wire [31:0] write_data,

    // UART output
    output reg         tx,

    // Status
    output reg         busy
);

    reg [7:0]  tx_data;
    reg [15:0] clock_count;
    reg [3:0]  bit_index;

    always @(posedge clk) begin

        if (rst) begin
            tx          <= 1'b1;
            busy        <= 1'b0;
            tx_data     <= 8'b0;
            clock_count <= 16'b0;
            bit_index   <= 4'b0;
        end

        else begin

            // Start a new transmission
            if (write_enable && !busy) begin

                tx_data     <= write_data[7:0];
                busy        <= 1'b1;
                clock_count <= 16'b0;
                bit_index   <= 4'd0;

                // Start bit
                tx          <= 1'b0;
            end

            else if (busy) begin

                if (clock_count >= CLKS_PER_BIT - 1) begin

                    clock_count <= 16'b0;

                    if (bit_index == 4'd0) begin
                        // Bit 0
                        tx        <= tx_data[0];
                        bit_index <= 4'd1;
                    end

                    else if (bit_index == 4'd1) begin
                        tx        <= tx_data[1];
                        bit_index <= 4'd2;
                    end

                    else if (bit_index == 4'd2) begin
                        tx        <= tx_data[2];
                        bit_index <= 4'd3;
                    end

                    else if (bit_index == 4'd3) begin
                        tx        <= tx_data[3];
                        bit_index <= 4'd4;
                    end

                    else if (bit_index == 4'd4) begin
                        tx        <= tx_data[4];
                        bit_index <= 4'd5;
                    end

                    else if (bit_index == 4'd5) begin
                        tx        <= tx_data[5];
                        bit_index <= 4'd6;
                    end

                    else if (bit_index == 4'd6) begin
                        tx        <= tx_data[6];
                        bit_index <= 4'd7;
                    end

                    else if (bit_index == 4'd7) begin
                        tx        <= tx_data[7];
                        bit_index <= 4'd8;
                    end

                    else begin
                        // Stop bit
                        tx        <= 1'b1;
                        bit_index <= 4'd9;
                    end

                    // Transmission complete
                    if (bit_index == 4'd9) begin
                        busy        <= 1'b0;
                        tx          <= 1'b1;
                        bit_index   <= 4'd0;
                        clock_count <= 16'b0;
                    end

                end

                else begin
                    clock_count <= clock_count + 16'd1;
                end

            end
        end
    end

endmodule