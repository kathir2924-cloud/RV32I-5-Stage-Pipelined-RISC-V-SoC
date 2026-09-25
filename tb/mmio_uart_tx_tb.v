`timescale 1ns/1ps

module mmio_uart_tx_tb;

    reg clk;
    reg rst;

    reg        write_enable;
    reg [31:0] write_data;

    wire tx;
    wire busy;

    mmio_uart_tx #(
        .CLKS_PER_BIT(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .write_data(write_data),
        .tx(tx),
        .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 1'b0;
        rst = 1'b1;

        write_enable = 1'b0;
        write_data   = 32'b0;

        $display("==============================================");
        $display("       UART TX STANDALONE TEST");
        $display("==============================================");

        #20;
        rst = 1'b0;

        // Send ASCII 'A' = 0x41
        @(posedge clk);
        write_data   <= 32'h00000041;
        write_enable <= 1'b1;

        @(posedge clk);
        write_enable <= 1'b0;

        // Wait until transmission completes
        wait(busy == 1'b1);

        $display("UART TX started");
        $display("Data = 0x%02h", 8'h41);

        wait(busy == 1'b0);

        $display("UART TX completed");
        $display("TX idle = %b", tx);

        if (tx == 1'b1) begin
            $display("");
            $display("==============================================");
            $display("       UART TX STANDALONE TEST PASS");
            $display("==============================================");
        end
        else begin
            $display("");
            $display("==============================================");
            $display("       UART TX STANDALONE TEST FAIL");
            $display("==============================================");
        end

        $finish;

    end

endmodule