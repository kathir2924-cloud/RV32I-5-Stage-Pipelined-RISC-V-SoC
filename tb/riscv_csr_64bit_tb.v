`timescale 1ns/1ps

module riscv_csr_64bit_tb;

    reg clk;
    reg rst;

    reg  [11:0] csr_addr;
    wire [31:0] csr_rdata;

    reg         csr_write;
    reg  [31:0] csr_wdata;

    reg         trap_enter;
    reg  [31:0] trap_pc;
    reg  [31:0] trap_cause;
    reg  [31:0] trap_value;

    reg         mret;

    reg         timer_interrupt;
    reg         uart_rx_interrupt;

    reg [63:0] cycle_count;
    reg [63:0] instret_count;

    wire [31:0] mtvec_value;
    wire [31:0] mepc_value;

    wire timer_interrupt_pending;
    wire uart_rx_interrupt_pending;


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
        .uart_rx_interrupt(uart_rx_interrupt),

        .cycle_count(cycle_count),
        .instret_count(instret_count),

        .mtvec_value(mtvec_value),
        .mepc_value(mepc_value),

        .timer_interrupt_pending(timer_interrupt_pending),
        .uart_rx_interrupt_pending(uart_rx_interrupt_pending)

    );


    // =========================================================
    // CLOCK
    // =========================================================

    initial begin

        clk = 1'b0;

        forever
            #5 clk = ~clk;

    end


    // =========================================================
    // TEST
    // =========================================================

    initial begin

        $display("");
        $display("==============================================");
        $display("       64-BIT CSR COUNTER TEST");
        $display("==============================================");
        $display("");


        // -----------------------------------------------------
        // RESET
        // -----------------------------------------------------

        rst = 1'b1;

        csr_addr = 12'b0;
        csr_write = 1'b0;
        csr_wdata = 32'b0;

        trap_enter = 1'b0;
        trap_pc = 32'b0;
        trap_cause = 32'b0;
        trap_value = 32'b0;

        mret = 1'b0;

        timer_interrupt = 1'b0;
        uart_rx_interrupt = 1'b0;

        cycle_count = 64'b0;
        instret_count = 64'b0;

        #20;

        rst = 1'b0;

        $display("CSR reset released");
        $display("");


        // =====================================================
        // LOAD KNOWN 64-BIT VALUES
        // =====================================================

        //
        // cycle_count =
        //
        //     0x12345678_9ABCDEF0
        //

        cycle_count = 64'h12345678_9ABCDEF0;


        //
        // instret_count =
        //
        //     0xFEDCBA98_76543210
        //

        instret_count = 64'hFEDCBA98_76543210;


        #10;


        // =====================================================
        // CYCLE LOW
        // =====================================================

        csr_addr = 12'hC00;

        #1;

        $display("CYCLE   = 0x%08h", csr_rdata);

        if (csr_rdata == 32'h9ABCDEF0)
            $display("PASS: CYCLE low 32 bits");
        else
            $display("FAIL: CYCLE low 32 bits");


        // =====================================================
        // CYCLE HIGH
        // =====================================================

        csr_addr = 12'hC80;

        #1;

        $display("CYCLEH  = 0x%08h", csr_rdata);

        if (csr_rdata == 32'h12345678)
            $display("PASS: CYCLEH high 32 bits");
        else
            $display("FAIL: CYCLEH high 32 bits");


        // =====================================================
        // TIME LOW
        // =====================================================

        csr_addr = 12'hC01;

        #1;

        $display("TIME    = 0x%08h", csr_rdata);

        if (csr_rdata == 32'h9ABCDEF0)
            $display("PASS: TIME low 32 bits");
        else
            $display("FAIL: TIME low 32 bits");


        // =====================================================
        // TIME HIGH
        // =====================================================

        csr_addr = 12'hC81;

        #1;

        $display("TIMEH   = 0x%08h", csr_rdata);

        if (csr_rdata == 32'h12345678)
            $display("PASS: TIMEH high 32 bits");
        else
            $display("FAIL: TIMEH high 32 bits");


        // =====================================================
        // INSTRET LOW
        // =====================================================

        csr_addr = 12'hC02;

        #1;

        $display("INSTRET = 0x%08h", csr_rdata);

        if (csr_rdata == 32'h76543210)
            $display("PASS: INSTRET low 32 bits");
        else
            $display("FAIL: INSTRET low 32 bits");


        // =====================================================
        // INSTRET HIGH
        // =====================================================

        csr_addr = 12'hC82;

        #1;

        $display("INSTRETH = 0x%08h", csr_rdata);

        if (csr_rdata == 32'hFEDCBA98)
            $display("PASS: INSTRETH high 32 bits");
        else
            $display("FAIL: INSTRETH high 32 bits");


        // =====================================================
        // FINAL RESULT
        // =====================================================

        csr_addr = 12'hC00;
        #1;

        if (csr_rdata == 32'h9ABCDEF0) begin

            csr_addr = 12'hC80;
            #1;

            if (csr_rdata == 32'h12345678) begin

                csr_addr = 12'hC02;
                #1;

                if (csr_rdata == 32'h76543210) begin

                    csr_addr = 12'hC82;
                    #1;

                    if (csr_rdata == 32'hFEDCBA98) begin

                        $display("");
                        $display("==============================================");
                        $display("       64-BIT CSR COUNTER TEST PASS");
                        $display("==============================================");

                    end
                    else begin

                        $display("");
                        $display("64-BIT CSR COUNTER TEST FAIL");

                    end

                end
                else begin

                    $display("");
                    $display("64-BIT CSR COUNTER TEST FAIL");

                end

            end
            else begin

                $display("");
                $display("64-BIT CSR COUNTER TEST FAIL");

            end

        end
        else begin

            $display("");
            $display("64-BIT CSR COUNTER TEST FAIL");

        end


        $finish;

    end

endmodule