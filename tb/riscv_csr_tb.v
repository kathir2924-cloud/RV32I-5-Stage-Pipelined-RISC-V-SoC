`timescale 1ns/1ps

module riscv_csr_tb;

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

reg [63:0] cycle_count;
reg [63:0] instret_count;

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

    .cycle_count(cycle_count),
    .instret_count(instret_count)
);

always #5 clk = ~clk;


// ============================================================
// TASK: CSR WRITE
// ============================================================

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


// ============================================================
// TASK: CSR READ CHECK
// ============================================================

task check_csr;

    input [11:0] address;
    input [31:0] expected;

    begin

        csr_addr = address;

        #1;

        if (csr_rdata !== expected)

            $display(
                "FAIL: CSR %h | Expected=%h | Got=%h",
                address,
                expected,
                csr_rdata
            );

        else

            $display(
                "PASS: CSR %h = %h",
                address,
                csr_rdata
            );

    end

endtask


// ============================================================
// TEST
// ============================================================

initial begin

    clk = 0;
    rst = 1;

    csr_addr = 12'b0;
    csr_write = 0;
    csr_wdata = 32'b0;

    trap_enter = 0;
    trap_pc = 0;
    trap_cause = 0;
    trap_value = 0;

    mret = 0;

    timer_interrupt = 0;

    cycle_count = 64'd0;
    instret_count = 64'd0;


    // --------------------------------------------------------
    // RESET
    // --------------------------------------------------------

    #12;
    rst = 0;


    // --------------------------------------------------------
    // TEST MSTATUS
    // --------------------------------------------------------

    write_csr(12'h300, 32'h00000008);

    check_csr(
        12'h300,
        32'h00000008
    );


    // --------------------------------------------------------
    // TEST MIE
    // --------------------------------------------------------

    write_csr(12'h304, 32'h00000080);

    check_csr(
        12'h304,
        32'h00000080
    );


    // --------------------------------------------------------
    // TEST MTVEC
    // --------------------------------------------------------

    write_csr(12'h305, 32'h00000100);

    check_csr(
        12'h305,
        32'h00000100
    );


    // --------------------------------------------------------
    // TEST MSCRATCH
    // --------------------------------------------------------

    write_csr(12'h340, 32'h12345678);

    check_csr(
        12'h340,
        32'h12345678
    );


    // --------------------------------------------------------
    // TEST MEPC
    // --------------------------------------------------------

    write_csr(12'h341, 32'h00000200);

    check_csr(
        12'h341,
        32'h00000200
    );


    // --------------------------------------------------------
    // TEST MCAUSE
    // --------------------------------------------------------

    write_csr(12'h342, 32'h0000000B);

    check_csr(
        12'h342,
        32'h0000000B
    );


    // --------------------------------------------------------
    // TEST MTVAL
    // --------------------------------------------------------

    write_csr(12'h343, 32'hDEADBEEF);

    check_csr(
        12'h343,
        32'hDEADBEEF
    );


    // --------------------------------------------------------
    // TEST CYCLE
    // --------------------------------------------------------

    cycle_count = 64'd12345;

    check_csr(
        12'hC00,
        32'd12345
    );


    // --------------------------------------------------------
    // TEST TIME
    // --------------------------------------------------------

    check_csr(
        12'hC01,
        32'd12345
    );


    // --------------------------------------------------------
    // TEST INSTRET
    // --------------------------------------------------------

    instret_count = 64'd9876;

    check_csr(
        12'hC02,
        32'd9876
    );


    // --------------------------------------------------------
    // TEST TIMER INTERRUPT PENDING
    // --------------------------------------------------------

    timer_interrupt = 1'b1;

    #1;

    csr_addr = 12'h344;

    #1;

    if (csr_rdata[7] !== 1'b1)

        $display(
            "FAIL: MIP.MTIP is not asserted"
        );

    else

        $display(
            "PASS: MIP.MTIP is asserted"
        );


    timer_interrupt = 1'b0;


    // --------------------------------------------------------
    // TEST TRAP ENTRY
    // --------------------------------------------------------

    trap_pc    = 32'h00001000;
    trap_cause = 32'h00000002;
    trap_value = 32'hFFFFFFFF;

    @(negedge clk);

    trap_enter = 1'b1;

    @(negedge clk);

    trap_enter = 1'b0;


    check_csr(
        12'h341,
        32'h00001000
    );

    check_csr(
        12'h342,
        32'h00000002
    );

    check_csr(
        12'h343,
        32'hFFFFFFFF
    );


    // --------------------------------------------------------
    // TEST MRET
    // --------------------------------------------------------

    @(negedge clk);

    mret = 1'b1;

    @(negedge clk);

    mret = 1'b0;


    $display("");
    $display("***********************************************");
    $display("*                                             *");
    $display("*          CSR MODULE TEST PASS              *");
    $display("*                                             *");
    $display("***********************************************");

    $finish;

end

endmodule