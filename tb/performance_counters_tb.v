`timescale 1ns/1ps

module performance_counters_tb;

    reg clk;
    reg rst;

    reg instruction_retired;
    reg stall;

    wire [63:0] cycle_count;
    wire [63:0] instret_count;
    wire [63:0] stall_count;

    // ============================================================
    // DUT
    // ============================================================

    performance_counters dut (
        .clk(clk),
        .rst(rst),
        .instruction_retired(instruction_retired),
        .stall(stall),
        .cycle_count(cycle_count),
        .instret_count(instret_count),
        .stall_count(stall_count)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ============================================================
    // TEST
    // ============================================================

    initial begin

        $display("==============================================");
        $display("     PERFORMANCE COUNTER UNIT TEST");
        $display("==============================================");

        rst = 1'b1;
        instruction_retired = 1'b0;
        stall = 1'b0;

        #20;

        rst = 1'b0;

        $display("CPU reset released");

        // --------------------------------------------------------
        // Test 1: Counters start from zero
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        if (cycle_count == 64'd1)
            $display("PASS: Cycle counter started");
        else
            $display("FAIL: Cycle counter = %0d", cycle_count);

        if (instret_count == 64'd0)
            $display("PASS: INSTRET initially zero");
        else
            $display("FAIL: INSTRET = %0d", instret_count);

        if (stall_count == 64'd0)
            $display("PASS: Stall counter initially zero");
        else
            $display("FAIL: Stall counter = %0d", stall_count);

        // --------------------------------------------------------
        // Test 2: Retire instructions
        // --------------------------------------------------------

        @(negedge clk);
        instruction_retired = 1'b1;
        stall = 1'b0;

        @(posedge clk);
        #1;

        @(negedge clk);
        instruction_retired = 1'b0;

        @(posedge clk);
        #1;

        if (instret_count == 64'd1)
            $display("PASS: One instruction retired");
        else
            $display("FAIL: INSTRET = %0d", instret_count);

        // --------------------------------------------------------
        // Test 3: Retire multiple instructions
        // --------------------------------------------------------

        repeat (4) begin
            @(negedge clk);
            instruction_retired = 1'b1;

            @(posedge clk);
            #1;
        end

        @(negedge clk);
        instruction_retired = 1'b0;

        @(posedge clk);
        #1;

        if (instret_count == 64'd5)
            $display("PASS: Five total instructions retired");
        else
            $display("FAIL: INSTRET = %0d", instret_count);

        // --------------------------------------------------------
        // Test 4: Stall counter
        // --------------------------------------------------------

        repeat (3) begin
            @(negedge clk);
            stall = 1'b1;

            @(posedge clk);
            #1;
        end

        @(negedge clk);
        stall = 1'b0;

        @(posedge clk);
        #1;

        if (stall_count == 64'd3)
            $display("PASS: Three stall cycles counted");
        else
            $display("FAIL: Stall count = %0d", stall_count);

        // --------------------------------------------------------
        // Test 5: Cycle counter continuously increments
        // --------------------------------------------------------

        if (cycle_count > 64'd5)
            $display("PASS: Cycle counter continuously increments");
        else
            $display("FAIL: Cycle counter = %0d", cycle_count);

        // --------------------------------------------------------
        // Final results
        // --------------------------------------------------------

        $display("");
        $display("========== FINAL COUNTER VALUES ==========");
        $display("CYCLE   = %0d", cycle_count);
        $display("INSTRET = %0d", instret_count);
        $display("STALL   = %0d", stall_count);
        $display("");

        if ((instret_count == 64'd5) &&
            (stall_count == 64'd3) &&
            (cycle_count > 64'd5)) begin

            $display("==============================================");
            $display("       PERFORMANCE COUNTER TEST PASS");
            $display("==============================================");

        end
        else begin

            $display("==============================================");
            $display("       PERFORMANCE COUNTER TEST FAIL");
            $display("==============================================");

        end

        $finish;
    end

endmodule