`timescale 1ns/1ps

module mmio_uart_rx #(
    parameter CLKS_PER_BIT = 4
)(
    input wire        clk,
    input wire        rst,
    input wire        rx,
    input wire        read_enable,
    output reg [31:0] read_data,
    output reg        data_valid,
    output wire receiving_status
);

    reg [7:0]  rx_data;
    reg [15:0] clock_count;
    reg [3:0]  bit_index;

    reg receiving;

    localparam HALF_BIT = CLKS_PER_BIT / 2;

    always @(posedge clk) begin

        if (rst) begin

            rx_data     <= 8'h00;
            clock_count <= 16'd0;
            bit_index   <= 4'd0;
            receiving   <= 1'b0;
            data_valid  <= 1'b0;

        end

        else begin

            data_valid <= 1'b0;

            // ==========================================
            // IDLE
            // ==========================================

            if (!receiving) begin

                if (rx == 1'b0) begin

                    // Start bit detected
                    receiving   <= 1'b1;
                    clock_count <= 16'd0;
                    bit_index   <= 4'd0;

                end

            end

            // ==========================================
            // RECEIVING
            // ==========================================

            else begin

                clock_count <= clock_count + 16'd1;

                // --------------------------------------
                // First wait half a bit before sampling
                // start bit / first data transition
                // --------------------------------------

                if (bit_index == 4'd0) begin

                    if (clock_count >= HALF_BIT - 1) begin

                        clock_count <= 16'd0;

                        // Verify start bit is still LOW
                        if (rx == 1'b0) begin
                            bit_index <= 4'd1;
                        end
                        else begin
                            // False start
                            receiving <= 1'b0;
                            bit_index <= 4'd0;
                        end

                    end

                end

                // --------------------------------------
                // Data bit 0
                // --------------------------------------

                else if (bit_index == 4'd1) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[0] <= rx;
                        bit_index <= 4'd2;

                    end

                end

                // --------------------------------------
                // Data bit 1
                // --------------------------------------

                else if (bit_index == 4'd2) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[1] <= rx;
                        bit_index <= 4'd3;

                    end

                end

                // --------------------------------------
                // Data bit 2
                // --------------------------------------

                else if (bit_index == 4'd3) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[2] <= rx;
                        bit_index <= 4'd4;

                    end

                end

                // --------------------------------------
                // Data bit 3
                // --------------------------------------

                else if (bit_index == 4'd4) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[3] <= rx;
                        bit_index <= 4'd5;

                    end

                end

                // --------------------------------------
                // Data bit 4
                // --------------------------------------

                else if (bit_index == 4'd5) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[4] <= rx;
                        bit_index <= 4'd6;

                    end

                end

                // --------------------------------------
                // Data bit 5
                // --------------------------------------

                else if (bit_index == 4'd6) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[5] <= rx;
                        bit_index <= 4'd7;

                    end

                end

                // --------------------------------------
                // Data bit 6
                // --------------------------------------

                else if (bit_index == 4'd7) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[6] <= rx;
                        bit_index <= 4'd8;

                    end

                end

                // --------------------------------------
                // Data bit 7
                // --------------------------------------

                else if (bit_index == 4'd8) begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;
                        rx_data[7] <= rx;
                        bit_index <= 4'd9;

                    end

                end

                // --------------------------------------
                // Stop bit
                // --------------------------------------

                else begin

                    if (clock_count >= CLKS_PER_BIT - 1) begin

                        clock_count <= 16'd0;

                        receiving  <= 1'b0;
                        data_valid <= 1'b1;
                        bit_index  <= 4'd0;

                    end

                end

            end

        end

    end

    // ==============================================
    // MMIO READ
    // ==============================================

    always @(*) begin

        if (read_enable)
            read_data = {24'b0, rx_data};
        else
            read_data = 32'b0;

    end
 assign receiving_status = receiving;

endmodule