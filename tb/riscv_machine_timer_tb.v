`timescale 1ns/1ps

module riscv_machine_timer_tb;

    reg clk;
    reg rst;
    reg enable;

    wire timer_interrupt;

    integer errors;
    integer cycle_count;


    machine_timer #(
        .TIMER_LIMIT(20)
    ) dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .timer_interrupt(timer_interrupt)
    );


    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    initial begin

        errors = 0;
        cycle_count = 0;

        rst = 1'b1;
        enable = 1'b1;

        $display("");
        $display("======================================================");
        $display("             MACHINE TIMER UNIT TEST");
        $display("======================================================");
        $display("");

        repeat (3)
            @(posedge clk);

        rst = 1'b0;

        $display("Timer reset released");


        // ========================================================
        // WAIT MAXIMUM 30 CLOCKS
        // ========================================================

        while (
            !timer_interrupt &&
            cycle_count < 30
        ) begin

            @(posedge clk);

            cycle_count = cycle_count + 1;

            $display(
                "Cycle=%0d  timer_interrupt=%b",
                cycle_count,
                timer_interrupt
            );

        end


        // ========================================================
        // CHECK ASSERTION
        // ========================================================

        if (timer_interrupt == 1'b1) begin

            $display(
                "PASS: Timer interrupt asserted"
            );

        end
        else begin

            $display(
                "FAIL: Timer did not assert within 30 cycles"
            );

            errors = errors + 1;

        end


        // ========================================================
        // CHECK LATCH
        // ========================================================

        repeat (5)
            @(posedge clk);


        if (timer_interrupt == 1'b1) begin

            $display(
                "PASS: Timer interrupt remains asserted"
            );

        end
        else begin

            $display(
                "FAIL: Timer interrupt was not retained"
            );

            errors = errors + 1;

        end


        // ========================================================
        // FINAL
        // ========================================================

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display(
                "          MACHINE TIMER TEST PASS"
            );

        end
        else begin

            $display(
                "          MACHINE TIMER TEST FAIL"
            );

            $display(
                "          ERROR COUNT = %0d",
                errors
            );

        end

        $display("======================================================");
        $display("");
$display("Timer IRQ       = %b", dut.timer_interrupt);
$display("MSTATUS         = 0x%08h", dut.csr_unit.mstatus);
$display("MIE             = 0x%08h", dut.csr_unit.mie);
$display("MIP             = 0x%08h", dut.csr_unit.mip);
$display(
    "Timer Pending   = %b",
    dut.timer_interrupt_pending
);
$display(
    "Interrupt Taken = %b",
    dut.interrupt_taken
);

$display("");
$display("--------------- TIMER DEBUG ----------------");
$display("Timer IRQ        = %b", dut.timer_interrupt);
$display("MSTATUS          = 0x%08h", dut.csr_unit.mstatus);
$display("MIE              = 0x%08h", dut.csr_unit.mie);
$display("MIP              = 0x%08h", dut.csr_unit.mip);
$display("Timer Pending    = %b", dut.timer_interrupt_pending);
$display("Interrupt Taken  = %b", dut.interrupt_taken);
$display("PC               = 0x%08h", dut.pc);
$display("MTVEC            = 0x%08h", dut.csr_unit.mtvec);
$display("----------------------------------------------");
$display("");
        $finish;

    end

endmodule