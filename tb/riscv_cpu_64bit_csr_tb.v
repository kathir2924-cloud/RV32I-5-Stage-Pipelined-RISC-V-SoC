`timescale 1ns/1ps

module riscv_cpu_64bit_csr_tb;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    reg clk;
    reg rst;

    // ============================================================
    // UART
    // ============================================================

    reg  uart_rx;
    wire uart_rx_irq;

    // ============================================================
    // INSTRUCTION MEMORY
    // ============================================================

    wire [31:0] imem_addr;
    reg  [31:0] imem_rdata;

    reg [31:0] instruction_memory [0:63];

    // ============================================================
    // DATA MEMORY
    // ============================================================

    wire        dmem_read;
    wire        dmem_write;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    wire [31:0] dmem_rdata;

    // No external data memory in this test
    assign dmem_rdata = 32'h00000000;

    // ============================================================
    // MMIO
    // ============================================================

    wire        mmio_read;
    wire        mmio_write;
    wire [31:0] mmio_addr;
    wire [31:0] mmio_wdata;
    wire [31:0] mmio_rdata;

    // No external MMIO in this test
    assign mmio_rdata = 32'h00000000;

    // ============================================================
    // INSTRUCTION MEMORY MODEL
    // ============================================================

    always @(*) begin
        if (imem_addr[31:2] < 64)
            imem_rdata = instruction_memory[imem_addr[31:2]];
        else
            imem_rdata = 32'h00000013;   // NOP
    end

    // ============================================================
    // CPU
    // ============================================================

    riscv_core #(
        .CSR_TEST(1'b0),
        .TRAP_TEST(1'b0),
        .TIMER_TEST(1'b0),
        .MMIO_TEST(1'b0),
        .UART_TX_TEST(1'b0),
        .UART_RX_TEST(1'b0),
        .UART_RX_INTERRUPT_TEST(1'b0),
        .SOC_MODE(1'b1)
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

        #25;

        rst = 1'b0;

        $display("");
        $display("==============================================");
        $display("       CPU 64-BIT CSR COUNTER TEST");
        $display("==============================================");
        $display("");
        $display("CPU reset released");
    end

    // ============================================================
    // PROGRAM
    //
    // 0x00000000:
    //     CSRR x5, CYCLEH
    //
    // 0x00000004:
    //     CSRR x6, INSTRETH
    //
    // 0x00000008:
    //     NOP
    //
    // 0x0000000C:
    //     NOP
    // ============================================================

    initial begin

        integer i;

        for (i = 0; i < 64; i = i + 1)
            instruction_memory[i] = 32'h00000013;

        // CSRRS x5, CYCLEH, x0
        instruction_memory[0] =
            {12'hC80, 5'd0, 3'b010, 5'd5, 7'b1110011};

        // CSRRS x6, INSTRETH, x0
        instruction_memory[1] =
            {12'hC82, 5'd0, 3'b010, 5'd6, 7'b1110011};

        // NOP
        instruction_memory[2] = 32'h00000013;

        // NOP
        instruction_memory[3] = 32'h00000013;

        // NOP
        instruction_memory[4] = 32'h00000013;

        // NOP
        instruction_memory[5] = 32'h00000013;

    end

    // ============================================================
    // TEST
    // ============================================================

    initial begin

        #25;

        // Wait for pipeline to execute
        repeat (30)
            @(posedge clk);

        #1;

        $display("");
        $display("==============================================");
        $display("       CPU 64-BIT CSR RESULTS");
        $display("==============================================");

        $display("");
        $display("Cycle Count     = 0x%016h", dut.cycle_count);
        $display("Instret Count   = 0x%016h", dut.instret_count);

        $display("");
        $display("CSR Address     = 0x%03h", dut.ex_csr_addr);
        $display("CSR Read Data   = 0x%08h", dut.csr_rdata);

        $display("");
        $display("WB RD           = x%0d", dut.wb_rd);
        $display("WB Data         = 0x%08h", dut.write_back_data);
        $display("WB Reg Write    = %b", dut.wb_reg_write);

        $display("");
        $display("==============================================");

        // --------------------------------------------------------
        // Basic counter sanity checks
        // --------------------------------------------------------

        if (dut.cycle_count != 64'd0) begin
            $display("PASS: 64-bit cycle counter is running");
        end
        else begin
            $display("FAIL: cycle counter did not increment");
        end

        if (dut.instret_count != 64'd0) begin
            $display("PASS: 64-bit instruction-retired counter is running");
        end
        else begin
            $display("FAIL: instruction-retired counter did not increment");
        end

        // --------------------------------------------------------
        // CSR address check
        // --------------------------------------------------------

        if (dut.ex_csr_addr == 12'hC82) begin
            $display("PASS: INSTRETH CSR reached CPU pipeline");
        end
        else begin
            $display("INFO: Final CSR address = 0x%03h",
                     dut.ex_csr_addr);
        end

        // --------------------------------------------------------
        // CSR read data check
        // --------------------------------------------------------

        if (dut.csr_rdata == dut.instret_count[63:32]) begin
            $display("PASS: INSTRETH returned correct upper 32 bits");
        end
        else begin
            $display("FAIL: INSTRETH returned incorrect value");
            $display("Expected = 0x%08h",
                     dut.instret_count[63:32]);
            $display("Actual   = 0x%08h",
                     dut.csr_rdata);
        end

        $display("");
        $display("==============================================");
        $display("       CPU 64-BIT CSR TEST COMPLETE");
        $display("==============================================");
        $display("");

        $finish;
    end

endmodule