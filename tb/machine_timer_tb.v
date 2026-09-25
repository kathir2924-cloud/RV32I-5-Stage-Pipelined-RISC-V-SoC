`timescale 1ns/1ps

module machine_timer_tb;

    reg clk;
    reg rst;
    reg enable;

    wire timer_interrupt;

    machine_timer #(
        .TIMER_LIMIT(5)
    ) dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .timer_interrupt(timer_interrupt)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // =========================================================
    // TEST
    // =========================================================

    initial begin

        rst    = 1'b1;
        enable = 1'b0;

        #20;

        rst    = 1'b0;
        enable = 1'b1;

        #100;

        $display("");
        $display("========================================");
        $display("       MACHINE TIMER TEST");
        $display("========================================");

        $display(
            "timer_interrupt = %b",
            timer_interrupt
        );

        if (timer_interrupt == 1'b1)

            $display("PASS: Timer interrupt generated");

        else

            $display("FAIL: Timer interrupt not generated");

        $display("");
        $display("========================================");
        $display("       TIMER TEST COMPLETE");
        $display("========================================");

        $finish;

    end

endmodule