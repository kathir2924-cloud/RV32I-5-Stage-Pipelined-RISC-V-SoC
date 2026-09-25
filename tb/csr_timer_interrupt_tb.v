`timescale 1ns/1ps

module csr_timer_interrupt_tb;

    reg clk;
    reg rst;

    reg [11:0] csr_addr;
    wire [31:0] csr_rdata;

    reg csr_write;
    reg [31:0] csr_wdata;

    reg trap_enter;
    reg [31:0] trap_pc;
    reg [31:0] trap_cause;
    reg [31:0] trap_value;

    reg mret;

    reg timer_interrupt;

    wire [31:0] mtvec_value;
    wire [31:0] mepc_value;

    wire timer_interrupt_pending;


    // =========================================================
    // DUT
    // =========================================================

    riscv_csr dut (
        .clk(clk),
        .rst(rst),

        .csr_addr(csr_addr),
        .csr_rdata(csr_rdata),

        .csr_write(csr_write),
        .csr_wdata(csr_wdata),

        .trap_enter(trap_enter),
        .trap_pc(trap_pc),
        .trap_cause(trap_cause),
        .trap_value(trap_value),

        .mret(mret),

        .timer_interrupt(timer_interrupt),

        .cycle_count(64'd0),
        .instret_count(64'd0),

        .mtvec_value(mtvec_value),
        .mepc_value(mepc_value),

        .timer_interrupt_pending(timer_interrupt_pending)
    );


    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // =========================================================
    // CSR WRITE TASK
    // =========================================================

    task write_csr;

        input [11:0] address;
        input [31:0] data;

        begin

            @(negedge clk);

            csr_addr  = address;
            csr_wdata = data;
            csr_write = 1'b1;

            @(negedge clk);

            csr_write = 1'b0;

        end

    endtask


    // =========================================================
    // TEST
    // =========================================================

    initial begin

        rst = 1'b1;

        csr_addr  = 12'b0;
        csr_write = 1'b0;
        csr_wdata = 32'b0;

        trap_enter = 1'b0;
        trap_pc = 32'b0;
        trap_cause = 32'b0;
        trap_value = 32'b0;

        mret = 1'b0;

        timer_interrupt = 1'b0;


        // -----------------------------------------------------
        // RESET
        // -----------------------------------------------------

        #20;

        rst = 1'b0;


        // -----------------------------------------------------
        // Enable MSTATUS.MIE (bit 3)
        // -----------------------------------------------------

        write_csr(
            12'h300,
            32'h00000008
        );


        // -----------------------------------------------------
        // Enable MIE.MTIE (bit 7)
        // -----------------------------------------------------

        write_csr(
            12'h304,
            32'h00000080
        );


        // -----------------------------------------------------
        // Generate timer interrupt
        // -----------------------------------------------------

        timer_interrupt = 1'b1;

        #20;


        // -----------------------------------------------------
        // DISPLAY
        // -----------------------------------------------------

        $display("");
        $display("========================================");
        $display("     CSR TIMER INTERRUPT TEST");
        $display("========================================");

        $display(
            "timer_interrupt_pending = %b",
            timer_interrupt_pending
        );


        // -----------------------------------------------------
        // CHECK
        // -----------------------------------------------------

        if (timer_interrupt_pending == 1'b1)

            $display(
                "PASS: Timer interrupt request generated"
            );

        else

            $display(
                "FAIL: Timer interrupt request NOT generated"
            );


        // -----------------------------------------------------
        // Disable timer interrupt
        // -----------------------------------------------------

        timer_interrupt = 1'b0;

        #10;


        if (timer_interrupt_pending == 1'b0)

            $display(
                "PASS: Timer interrupt request cleared"
            );

        else

            $display(
                "FAIL: Timer interrupt request did not clear"
            );


        $display("");
        $display("========================================");
        $display("     CSR TIMER TEST COMPLETE");
        $display("========================================");

        $finish;

    end

endmodule