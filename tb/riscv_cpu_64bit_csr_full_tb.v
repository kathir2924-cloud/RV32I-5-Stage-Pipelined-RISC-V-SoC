`timescale 1ns/1ps

module riscv_cpu_64bit_csr_full_tb;

    reg clk;
    reg rst;
    reg uart_rx;

    wire [31:0] imem_addr;
    reg  [31:0] imem_rdata;

    wire        dmem_read;
    wire        dmem_write;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    reg  [31:0] dmem_rdata;

    wire        mmio_read;
    wire        mmio_write;
    wire [31:0] mmio_addr;
    wire [31:0] mmio_wdata;
    reg  [31:0] mmio_rdata;

    wire uart_rx_irq;

    assign uart_rx_irq = 1'b0;

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ============================================================
    // RESET
    // ============================================================

    initial begin
        rst     = 1'b1;
        uart_rx = 1'b1;

        #20;

        rst = 1'b0;

        $display("");
        $display("==============================================");
        $display("     CPU 64-BIT CSR PIPELINE TEST");
        $display("==============================================");
        $display("");
        $display("CPU reset released");
    end

    // ============================================================
    // DUT
    // ============================================================

    riscv_core #(
        .CSR_TEST               (1'b0),
        .TRAP_TEST              (1'b0),
        .TIMER_TEST             (1'b0),
        .MMIO_TEST              (1'b0),
        .UART_TX_TEST           (1'b0),
        .UART_RX_TEST           (1'b0),
        .UART_RX_INTERRUPT_TEST (1'b0),
        .SOC_MODE               (1'b1)
    ) dut (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx),

        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),

        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata),

        .mmio_read(mmio_read),
        .mmio_write(mmio_write),
        .mmio_addr(mmio_addr),
        .mmio_wdata(mmio_wdata),
        .mmio_rdata(mmio_rdata),

        .uart_rx_irq(uart_rx_irq)
    );

    // ============================================================
    // DEFAULT MEMORY INPUTS
    // ============================================================

    initial begin
        dmem_rdata = 32'b0;
        mmio_rdata = 32'b0;
    end

    // ============================================================
    // INSTRUCTION MEMORY
    // ============================================================

    reg [31:0] instruction_memory [0:255];

    integer i;

    initial begin

        for (i = 0; i < 256; i = i + 1)
            instruction_memory[i] = 32'h00000013; // NOP

        // --------------------------------------------------------
        // CSRRS rd, csr, x0
        //
        // funct3 = 010
        // rs1    = x0
        // opcode = 1110011
        // --------------------------------------------------------

        // CYCLE
        instruction_memory[0] =
            {12'hC00, 5'd0, 3'b010, 5'd5, 7'b1110011};

        // CYCLEH
        instruction_memory[1] =
            {12'hC80, 5'd0, 3'b010, 5'd6, 7'b1110011};

        // TIME
        instruction_memory[2] =
            {12'hC01, 5'd0, 3'b010, 5'd7, 7'b1110011};

        // TIMEH
        instruction_memory[3] =
            {12'hC81, 5'd0, 3'b010, 5'd8, 7'b1110011};

        // INSTRET
        instruction_memory[4] =
            {12'hC02, 5'd0, 3'b010, 5'd9, 7'b1110011};

        // INSTRETH
        instruction_memory[5] =
            {12'hC82, 5'd0, 3'b010, 5'd10, 7'b1110011};

        // NOPs
        for (i = 6; i < 256; i = i + 1)
            instruction_memory[i] = 32'h00000013;
    end

    // ============================================================
    // INSTRUCTION MEMORY READ
    // ============================================================

    always @(*) begin

        if (imem_addr[31:2] < 256)
            imem_rdata = instruction_memory[imem_addr[31:2]];
        else
            imem_rdata = 32'h00000013;

    end

    // ============================================================
    // EXPECTED VALUES
    // ============================================================

    reg [31:0] expected_cycle;
    reg [31:0] expected_cycleh;

    reg [31:0] expected_time;
    reg [31:0] expected_timeh;

    reg [31:0] expected_instret;
    reg [31:0] expected_instreth;

    reg expected_cycle_valid;
    reg expected_cycleh_valid;

    reg expected_time_valid;
    reg expected_timeh_valid;

    reg expected_instret_valid;
    reg expected_instreth_valid;

    integer errors;

    initial begin

        expected_cycle      = 32'b0;
        expected_cycleh     = 32'b0;

        expected_time       = 32'b0;
        expected_timeh      = 32'b0;

        expected_instret    = 32'b0;
        expected_instreth   = 32'b0;

        expected_cycle_valid    = 1'b0;
        expected_cycleh_valid   = 1'b0;

        expected_time_valid     = 1'b0;
        expected_timeh_valid    = 1'b0;

        expected_instret_valid  = 1'b0;
        expected_instreth_valid = 1'b0;

        errors = 0;

    end

    // ============================================================
    // CAPTURE CSR READ AT EX STAGE
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            if (dut.ex_valid && dut.ex_csr_read) begin

                case (dut.ex_csr_addr)

                    12'hC00: begin
                        expected_cycle = dut.csr_rdata;
                        expected_cycle_valid = 1'b1;

                        $display(
                            "EX: CYCLE   csr=0x%03h data=0x%08h",
                            dut.ex_csr_addr,
                            dut.csr_rdata
                        );
                    end

                    12'hC80: begin
                        expected_cycleh = dut.csr_rdata;
                        expected_cycleh_valid = 1'b1;

                        $display(
                            "EX: CYCLEH  csr=0x%03h data=0x%08h",
                            dut.ex_csr_addr,
                            dut.csr_rdata
                        );
                    end

                    12'hC01: begin
                        expected_time = dut.csr_rdata;
                        expected_time_valid = 1'b1;

                        $display(
                            "EX: TIME    csr=0x%03h data=0x%08h",
                            dut.ex_csr_addr,
                            dut.csr_rdata
                        );
                    end

                    12'hC81: begin
                        expected_timeh = dut.csr_rdata;
                        expected_timeh_valid = 1'b1;

                        $display(
                            "EX: TIMEH   csr=0x%03h data=0x%08h",
                            dut.ex_csr_addr,
                            dut.csr_rdata
                        );
                    end

                    12'hC02: begin
                        expected_instret = dut.csr_rdata;
                        expected_instret_valid = 1'b1;

                        $display(
                            "EX: INSTRET csr=0x%03h data=0x%08h",
                            dut.ex_csr_addr,
                            dut.csr_rdata
                        );
                    end

                    12'hC82: begin
                        expected_instreth = dut.csr_rdata;
                        expected_instreth_valid = 1'b1;

                        $display(
                            "EX: INSTRETH csr=0x%03h data=0x%08h",
                            dut.ex_csr_addr,
                            dut.csr_rdata
                        );
                    end

                    default: begin
                    end

                endcase

            end

        end

    end

    // ============================================================
    // WRITEBACK OBSERVATION
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            if (dut.wb_valid && dut.wb_reg_write) begin

                $display(
                    "WB: x%0d DATA=0x%08h",
                    dut.wb_rd,
                    dut.write_back_data
                );

                case (dut.wb_rd)

                    5: begin
                        if (expected_cycle_valid) begin

                            if (dut.write_back_data !== expected_cycle) begin
                                $display(
                                    "FAIL: CYCLE WB mismatch expected=0x%08h actual=0x%08h",
                                    expected_cycle,
                                    dut.write_back_data
                                );

                                errors = errors + 1;
                            end
                            else begin
                                $display(
                                    "PASS: CYCLE WB = 0x%08h",
                                    dut.write_back_data
                                );
                            end

                        end
                    end

                    6: begin
                        if (expected_cycleh_valid) begin

                            if (dut.write_back_data !== expected_cycleh) begin
                                $display(
                                    "FAIL: CYCLEH WB mismatch expected=0x%08h actual=0x%08h",
                                    expected_cycleh,
                                    dut.write_back_data
                                );

                                errors = errors + 1;
                            end
                            else begin
                                $display(
                                    "PASS: CYCLEH WB = 0x%08h",
                                    dut.write_back_data
                                );
                            end

                        end
                    end

                    7: begin
                        if (expected_time_valid) begin

                            if (dut.write_back_data !== expected_time) begin
                                $display(
                                    "FAIL: TIME WB mismatch expected=0x%08h actual=0x%08h",
                                    expected_time,
                                    dut.write_back_data
                                );

                                errors = errors + 1;
                            end
                            else begin
                                $display(
                                    "PASS: TIME WB = 0x%08h",
                                    dut.write_back_data
                                );
                            end

                        end
                    end

                    8: begin
                        if (expected_timeh_valid) begin

                            if (dut.write_back_data !== expected_timeh) begin
                                $display(
                                    "FAIL: TIMEH WB mismatch expected=0x%08h actual=0x%08h",
                                    expected_timeh,
                                    dut.write_back_data
                                );

                                errors = errors + 1;
                            end
                            else begin
                                $display(
                                    "PASS: TIMEH WB = 0x%08h",
                                    dut.write_back_data
                                );
                            end

                        end
                    end

                    9: begin
                        if (expected_instret_valid) begin

                            if (dut.write_back_data !== expected_instret) begin
                                $display(
                                    "FAIL: INSTRET WB mismatch expected=0x%08h actual=0x%08h",
                                    expected_instret,
                                    dut.write_back_data
                                );

                                errors = errors + 1;
                            end
                            else begin
                                $display(
                                    "PASS: INSTRET WB = 0x%08h",
                                    dut.write_back_data
                                );
                            end

                        end
                    end

                    10: begin
                        if (expected_instreth_valid) begin

                            if (dut.write_back_data !== expected_instreth) begin
                                $display(
                                    "FAIL: INSTRETH WB mismatch expected=0x%08h actual=0x%08h",
                                    expected_instreth,
                                    dut.write_back_data
                                );

                                errors = errors + 1;
                            end
                            else begin
                                $display(
                                    "PASS: INSTRETH WB = 0x%08h",
                                    dut.write_back_data
                                );
                            end

                        end
                    end

                    default: begin
                    end

                endcase

            end

        end

    end

    // ============================================================
    // FINAL CHECK
    // ============================================================

    initial begin

        #500;

        $display("");
        $display("==============================================");
        $display("       CPU 64-BIT CSR FINAL RESULTS");
        $display("==============================================");

        $display(
            "Cycle Count   = 0x%016h",
            dut.cycle_count
        );

        $display(
            "Instret Count = 0x%016h",
            dut.instret_count
        );

        $display("");

        if (expected_cycle_valid)
            $display(
                "CYCLE   captured = 0x%08h",
                expected_cycle
            );
        else begin
            $display("FAIL: CYCLE was never observed in EX");
            errors = errors + 1;
        end

        if (expected_cycleh_valid)
            $display(
                "CYCLEH  captured = 0x%08h",
                expected_cycleh
            );
        else begin
            $display("FAIL: CYCLEH was never observed in EX");
            errors = errors + 1;
        end

        if (expected_time_valid)
            $display(
                "TIME    captured = 0x%08h",
                expected_time
            );
        else begin
            $display("FAIL: TIME was never observed in EX");
            errors = errors + 1;
        end

        if (expected_timeh_valid)
            $display(
                "TIMEH   captured = 0x%08h",
                expected_timeh
            );
        else begin
            $display("FAIL: TIMEH was never observed in EX");
            errors = errors + 1;
        end

        if (expected_instret_valid)
            $display(
                "INSTRET captured = 0x%08h",
                expected_instret
            );
        else begin
            $display("FAIL: INSTRET was never observed in EX");
            errors = errors + 1;
        end

        if (expected_instreth_valid)
            $display(
                "INSTRETH captured = 0x%08h",
                expected_instreth
            );
        else begin
            $display("FAIL: INSTRETH was never observed in EX");
            errors = errors + 1;
        end

        $display("");

        if (errors == 0) begin

            $display("==============================================");
            $display("     CPU 64-BIT CSR PIPELINE TEST PASS");
            $display("==============================================");

        end
        else begin

            $display("==============================================");
            $display(
                " CPU 64-BIT CSR PIPELINE TEST FAIL - %0d ERRORS",
                errors
            );
            $display("==============================================");

        end

        $finish;

    end

endmodule