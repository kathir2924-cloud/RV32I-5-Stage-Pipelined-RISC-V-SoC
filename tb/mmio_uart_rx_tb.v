`timescale 1ns/1ps

module mmio_uart_rx_tb;

    reg clk;
    reg rst;

    reg rx;

    reg        read_enable;
    wire [31:0] read_data;
    wire        data_valid;

    mmio_uart_rx #(
        .CLKS_PER_BIT(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .read_enable(read_enable),
        .read_data(read_data),
        .data_valid(data_valid)
    );

    always #5 clk = ~clk;

    // Send one UART bit
    task send_bit;
        input bit_value;
        begin
            rx = bit_value;
            repeat (4) @(posedge clk);
        end
    endtask

    // Send one UART byte, 8-N-1
    task send_byte;
        input [7:0] data;
        integer i;

        begin

            // Start bit
            send_bit(1'b0);

            // Data bits LSB first
            for (i = 0; i < 8; i = i + 1)
                send_bit(data[i]);

            // Stop bit
            send_bit(1'b1);

        end
    endtask

    initial begin

        clk = 1'b0;
        rst = 1'b1;
        rx = 1'b1;
        read_enable = 1'b0;

        $display("==============================================");
        $display("       UART RX STANDALONE TEST");
        $display("==============================================");

        #20;
        rst = 1'b0;

        // Send ASCII 'A'
        send_byte(8'h41);

        // Give receiver time to finish
        repeat (4) @(posedge clk);

        read_enable = 1'b1;
        #1;

        $display("");
        $display("Received data = 0x%08h", read_data);
        $display("Data valid     = %b", data_valid);

        if (read_data == 32'h00000041) begin

            $display("");
            $display("==============================================");
            $display("       UART RX STANDALONE TEST PASS");
            $display("==============================================");

        end
        else begin

            $display("");
            $display("==============================================");
            $display("       UART RX STANDALONE TEST FAIL");
            $display("==============================================");

        end

        $finish;

    end

endmodule