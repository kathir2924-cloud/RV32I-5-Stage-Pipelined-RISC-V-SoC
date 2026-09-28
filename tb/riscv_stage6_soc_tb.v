`timescale 1ns/1ps

module riscv_stage6_soc_tb;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    reg clk;
    reg rst;
    reg uart_rx;

    integer errors;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

    riscv_soc #(
        .RAM_ADDR_WIDTH(12)
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .uart_rx (uart_rx)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ============================================================
    // HELPERS
    // ============================================================

    task clear_memories;
        integer i;
        begin

            for (i = 0; i < 4096; i = i + 1) begin
                dut.imem_ram.mem[i] = 32'h00000013;
                dut.dmem_ram.mem[i] = 32'h00000000;
            end

        end
    endtask

    task reset_soc;
        begin

            rst     = 1'b1;
            uart_rx = 1'b1;

            repeat (5)
                @(posedge clk);

            rst = 1'b0;

            repeat (5)
                @(posedge clk);

        end
    endtask

    task write_imem;
        input [31:0] addr;
        input [31:0] data;

        begin
            dut.imem_ram.mem[addr[13:2]] = data;
        end
    endtask

    task write_dmem;
        input [31:0] addr;
        input [31:0] data;

        begin
            dut.dmem_ram.mem[addr[13:2]] = data;
        end
    endtask

    task wait_cycles;
        input integer count;

        integer i;

        begin

            for (i = 0; i < count; i = i + 1)
                @(posedge clk);

        end
    endtask

    // ============================================================
    // RISC-V ENCODING HELPERS
    // ============================================================

    function [31:0] enc_i;
        input [11:0] imm;
        input [4:0]  rs1_f;
        input [2:0]  funct3;
        input [4:0]  rd_f;
        input [6:0]  opcode;

        begin
            enc_i = {
                imm,
                rs1_f,
                funct3,
                rd_f,
                opcode
            };
        end
    endfunction

    function [31:0] enc_r;
        input [6:0] funct7;
        input [4:0] rs2_f;
        input [4:0] rs1_f;
        input [2:0] funct3;
        input [4:0] rd_f;
        input [6:0] opcode;

        begin
            enc_r = {
                funct7,
                rs2_f,
                rs1_f,
                funct3,
                rd_f,
                opcode
            };
        end
    endfunction

    function [31:0] enc_s;
        input [11:0] imm;
        input [4:0]  rs2_f;
        input [4:0]  rs1_f;
        input [2:0]  funct3;
        input [6:0]  opcode;

        begin
            enc_s = {
                imm[11:5],
                rs2_f,
                rs1_f,
                funct3,
                imm[4:0],
                opcode
            };
        end
    endfunction

    function [31:0] enc_b;
        input integer offset;
        input [4:0] rs2_f;
        input [4:0] rs1_f;
        input [2:0] funct3;

        reg [12:0] imm;

        begin

            imm = offset[12:0];

            enc_b = {
                imm[12],
                imm[10:5],
                rs2_f,
                rs1_f,
                funct3,
                imm[4:1],
                imm[11],
                1'b0,
                7'b1100011
            };

        end
    endfunction

    function [31:0] enc_u;
        input [19:0] imm;
        input [4:0] rd_f;
        input [6:0] opcode;

        begin

            enc_u = {
                imm,
                rd_f,
                opcode
            };

        end
    endfunction

    // ============================================================
    // CONSTANTS
    // ============================================================

    localparam [31:0] GPIO_ADDR =
        32'h10000000;

    localparam [31:0] UART_TX_ADDR =
        32'h10000004;

    localparam [31:0] UART_RX_ADDR =
        32'h10000008;

    localparam [31:0] STATUS_ADDR =
        32'h10000010;

    localparam [31:0] CONTROL_ADDR =
        32'h10000014;

    localparam [31:0] MTVEC_ADDR =
        32'h00000100;

    localparam [31:0] MSTATUS_ADDR =
        32'h00000300;

    localparam [31:0] MIE_ADDR =
        32'h00000304;

    localparam [31:0] MEPC_ADDR =
        32'h00000341;

    localparam [31:0] MCAUSE_ADDR =
        32'h00000342;

    localparam [31:0] MTVAL_ADDR =
        32'h00000343;

    localparam [31:0] CYCLE_ADDR =
        32'h00000C00;

    localparam [31:0] TIME_ADDR =
        32'h00000C01;

    localparam [31:0] INSTRET_ADDR =
        32'h00000C02;

    // ============================================================
    // MAIN SOC PROGRAM
    //
    // Tests:
    //   - arithmetic
    //   - RAM store/load
    //   - GPIO
    //   - UART TX
    //   - STATUS
    //   - CONTROL
    //   - UART RX interrupt enable
    //   - CSR
    //   - ECALL
    //   - MRET
    //   - interrupt handling
    //
    // ============================================================

    task load_main_program;

        begin

            // ----------------------------------------------------
            // x1 = 0x10000000
            // ----------------------------------------------------

            write_imem(
                32'h0000,
                enc_u(
                    20'h10000,
                    5'd1,
                    7'b0110111
                )
            );

            // ----------------------------------------------------
            // x2 = 0x55
            // ----------------------------------------------------

            write_imem(
                32'h0004,
                enc_i(
                    12'h055,
                    5'd0,
                    3'b000,
                    5'd2,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // GPIO WRITE
            //
            // SW x2, 0(x1)
            // ----------------------------------------------------

            write_imem(
                32'h0008,
                enc_s(
                    12'h000,
                    5'd2,
                    5'd1,
                    3'b010,
                    7'b0100011
                )
            );

            // ----------------------------------------------------
            // x3 = 0xAA
            // ----------------------------------------------------

            write_imem(
                32'h000C,
                enc_i(
                    12'h0AA,
                    5'd0,
                    3'b000,
                    5'd3,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // RAM ADDRESS
            // x4 = 0x00000100
            // ----------------------------------------------------

            write_imem(
                32'h0010,
                enc_i(
                    12'h100,
                    5'd0,
                    3'b000,
                    5'd4,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // STORE x3 -> RAM[0x100]
            // ----------------------------------------------------

            write_imem(
                32'h0014,
                enc_s(
                    12'h000,
                    5'd3,
                    5'd4,
                    3'b010,
                    7'b0100011
                )
            );

            // ----------------------------------------------------
            // LOAD RAM[0x100] -> x5
            // ----------------------------------------------------

            write_imem(
                32'h0018,
                enc_i(
                    12'h000,
                    5'd4,
                    3'b010,
                    5'd5,
                    7'b0000011
                )
            );

            // ----------------------------------------------------
            // x6 = 0x10000004
            // UART TX
            // ----------------------------------------------------

            write_imem(
                32'h001C,
                enc_u(
                    20'h10000,
                    5'd6,
                    7'b0110111
                )
            );

            write_imem(
                32'h0020,
                enc_i(
                    12'h004,
                    5'd6,
                    3'b000,
                    5'd6,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // UART TX = 'A'
            // ----------------------------------------------------

            write_imem(
                32'h0024,
                enc_i(
                    12'h041,
                    5'd0,
                    3'b000,
                    5'd7,
                    7'b0010011
                )
            );

            write_imem(
                32'h0028,
                enc_s(
                    12'h000,
                    5'd7,
                    5'd6,
                    3'b010,
                    7'b0100011
                )
            );

            // ----------------------------------------------------
            // STATUS ADDRESS
            //
            // x8 = 0x10000010
            // ----------------------------------------------------

            write_imem(
                32'h002C,
                enc_u(
                    20'h10000,
                    5'd8,
                    7'b0110111
                )
            );

            write_imem(
                32'h0030,
                enc_i(
                    12'h010,
                    5'd8,
                    3'b000,
                    5'd8,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // STATUS READ
            // ----------------------------------------------------

            write_imem(
                32'h0034,
                enc_i(
                    12'h000,
                    5'd8,
                    3'b010,
                    5'd9,
                    7'b0000011
                )
            );

            // ----------------------------------------------------
            // CONTROL ADDRESS
            //
            // x10 = 0x10000014
            // ----------------------------------------------------

            write_imem(
                32'h0038,
                enc_u(
                    20'h10000,
                    5'd10,
                    7'b0110111
                )
            );

            write_imem(
                32'h003C,
                enc_i(
                    12'h014,
                    5'd10,
                    3'b000,
                    5'd10,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // ENABLE UART RX INTERRUPT
            // x11 = 1
            // ----------------------------------------------------

            write_imem(
                32'h0040,
                enc_i(
                    12'h001,
                    5'd0,
                    3'b000,
                    5'd11,
                    7'b0010011
                )
            );

            write_imem(
                32'h0044,
                enc_s(
                    12'h000,
                    5'd11,
                    5'd10,
                    3'b010,
                    7'b0100011
                )
            );

            // ----------------------------------------------------
            // MTVEC = 0x100
            //
            // x12 = 0x100
            // ----------------------------------------------------

            write_imem(
                32'h0048,
                enc_i(
                    12'h100,
                    5'd0,
                    3'b000,
                    5'd12,
                    7'b0010011
                )
            );

            // CSRRW x0, MTVEC, x12
            write_imem(
                32'h004C,
                32'h30561073
            );

            // ----------------------------------------------------
            // ENABLE MSTATUS.MIE
            //
            // x13 = 8
            // ----------------------------------------------------

            write_imem(
                32'h0050,
                enc_i(
                    12'h008,
                    5'd0,
                    3'b000,
                    5'd13,
                    7'b0010011
                )
            );

            // CSRRS x0,MSTATUS,x13
            write_imem(
                32'h0054,
                32'h3006A073
            );

            // ----------------------------------------------------
            // ENABLE MEIE + MTIE
            //
            // x14 = 0x880
            // ----------------------------------------------------

            write_imem(
                32'h0058,
                enc_i(
                    12'h880,
                    5'd0,
                    3'b000,
                    5'd14,
                    7'b0010011
                )
            );

            // CSRRS x0,MIE,x14
            write_imem(
                32'h005C,
                32'h30472073
            );

            // ----------------------------------------------------
            // NORMAL COMPUTATION
            // ----------------------------------------------------

            write_imem(
                32'h0060,
                enc_i(
                    12'h011,
                    5'd0,
                    3'b000,
                    5'd15,
                    7'b0010011
                )
            );

            write_imem(
                32'h0064,
                enc_i(
                    12'h022,
                    5'd0,
                    3'b000,
                    5'd16,
                    7'b0010011
                )
            );

            write_imem(
                32'h0068,
                enc_r(
                    7'b0000000,
                    5'd16,
                    5'd15,
                    3'b000,
                    5'd17,
                    7'b0110011
                )
            );

            // ----------------------------------------------------
            // ECALL
            // ----------------------------------------------------

            write_imem(
                32'h006C,
                32'h00000073
            );

            // ----------------------------------------------------
            // POST ECALL
            // ----------------------------------------------------

            write_imem(
                32'h0070,
                enc_i(
                    12'h055,
                    5'd0,
                    3'b000,
                    5'd18,
                    7'b0010011
                )
            );

            write_imem(
                32'h0074,
                enc_i(
                    12'h066,
                    5'd0,
                    3'b000,
                    5'd19,
                    7'b0010011
                )
            );

            write_imem(
                32'h0078,
                enc_r(
                    7'b0000000,
                    5'd19,
                    5'd18,
                    3'b000,
                    5'd20,
                    7'b0110011
                )
            );

            // ----------------------------------------------------
            // LOOP
            // ----------------------------------------------------

            write_imem(
                32'h007C,
                enc_b(
                    -4,
                    5'd0,
                    5'd0,
                    3'b000
                )
            );

        end

    endtask

    // ============================================================
    // TRAP / INTERRUPT HANDLER
    //
    // 0x100:
    //
    // x21 = MCAUSE
    // x22 = MEPC
    // x23 = MSTATUS
    //
    // MEPC += 4
    //
    // For ECALL:
    //   return to next instruction
    //
    // For interrupts:
    //   clear interrupt enables
    //   return using MRET
    //
    // ============================================================

    task load_trap_handler;

        begin

            // ----------------------------------------------------
            // x21 = MCAUSE
            // ----------------------------------------------------

            write_imem(
                32'h0100,
                enc_i(
                    12'h342,
                    5'd0,
                    3'b010,
                    5'd21,
                    7'b1110011
                )
            );

            // ----------------------------------------------------
            // x22 = MEPC
            // ----------------------------------------------------

            write_imem(
                32'h0104,
                enc_i(
                    12'h341,
                    5'd0,
                    3'b010,
                    5'd22,
                    7'b1110011
                )
            );

            // ----------------------------------------------------
            // x23 = MSTATUS
            // ----------------------------------------------------

            write_imem(
                32'h0108,
                enc_i(
                    12'h300,
                    5'd0,
                    3'b010,
                    5'd23,
                    7'b1110011
                )
            );

            // ----------------------------------------------------
            // x24 = 4
            // ----------------------------------------------------

            write_imem(
                32'h010C,
                enc_i(
                    12'h004,
                    5'd0,
                    3'b000,
                    5'd24,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // MEPC = MEPC + 4
            // ----------------------------------------------------

            write_imem(
                32'h0110,
                enc_r(
                    7'b0000000,
                    5'd24,
                    5'd22,
                    3'b000,
                    5'd22,
                    7'b0110011
                )
            );

            // ----------------------------------------------------
            // CSRRW x0,MEPC,x22
            // ----------------------------------------------------

            write_imem(
                32'h0114,
                32'h341B1073
            );

            // ----------------------------------------------------
            // Clear MTIE + MEIE
            //
            // x25 = 0x880
            // ----------------------------------------------------

            write_imem(
                32'h0118,
                enc_i(
                    12'h880,
                    5'd0,
                    3'b000,
                    5'd25,
                    7'b0010011
                )
            );

            // ----------------------------------------------------
            // CSRRC x0,MIE,x25
            // ----------------------------------------------------

            write_imem(
                32'h011C,
                32'h304BB073
            );

            // ----------------------------------------------------
            // MRET
            // ----------------------------------------------------

            write_imem(
                32'h0120,
                32'h30200073
            );

        end

    endtask

    // ============================================================
    // MAIN TEST
    // ============================================================

    initial begin

        errors = 0;

        $display("");
        $display("======================================================");
        $display("       STAGE 6 - FULL RISC-V SOC REGRESSION");
        $display("======================================================");
        $display("");

        // --------------------------------------------------------
        // INITIALIZE
        // --------------------------------------------------------

        clear_memories();

        load_main_program();

        load_trap_handler();

        reset_soc();

        // --------------------------------------------------------
        // WAIT FOR PROGRAM / TRAP / INTERRUPT ACTIVITY
        // --------------------------------------------------------

        wait_cycles(300);

        // ========================================================
        // CPU REGISTERS
        // ========================================================

        $display("");
        $display("---------------- CPU REGRESSION ----------------");

        if (dut.core.registers.registers[2] == 32'h00000055) begin
            $display("PASS: Arithmetic immediate");
        end
        else begin
            $display(
                "FAIL: Arithmetic immediate x2 = 0x%08h",
                dut.core.registers.registers[2]
            );
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // x5 should contain RAM-loaded 0xAA
        // --------------------------------------------------------

        if (dut.core.registers.registers[5] == 32'h000000AA) begin
            $display("PASS: RAM store/load");
        end
        else begin
            $display(
                "FAIL: RAM store/load x5 = 0x%08h",
                dut.core.registers.registers[5]
            );
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // x17 = 0x33
        // --------------------------------------------------------

        // --------------------------------------------------------
// Integrated CPU execution result
// --------------------------------------------------------

if (dut.core.registers.registers[20] == 32'h000000BB) begin
    $display("PASS: Integrated CPU execution");
end
else begin
    $display(
        "FAIL: Integrated CPU result x20 = 0x%08h",
        dut.core.registers.registers[20]
    );
    errors = errors + 1;
end

        // --------------------------------------------------------
        // x20 = 0xBB
        // --------------------------------------------------------

        if (dut.core.registers.registers[20] == 32'h000000BB) begin
            $display("PASS: Post-trap program execution");
        end
        else begin
            $display(
                "FAIL: Post-trap execution x20 = 0x%08h",
                dut.core.registers.registers[20]
            );
            errors = errors + 1;
        end

        // ========================================================
        // GPIO
        // ========================================================

        $display("");
        $display("---------------- GPIO ----------------");

        if (dut.gpio_out == 32'h00000055) begin
            $display("PASS: GPIO MMIO write");
        end
        else begin
            $display(
                "FAIL: GPIO output = 0x%08h",
                dut.gpio_out
            );
            errors = errors + 1;
        end

        // ========================================================
        // RAM
        // ========================================================

        $display("");
        $display("---------------- DATA RAM ----------------");

        if (dut.dmem_ram.mem[32'h100 >> 2] == 32'h000000AA) begin
            $display("PASS: Data RAM transaction");
        end
        else begin
            $display(
                "FAIL: Data RAM[0x100] = 0x%08h",
                dut.dmem_ram.mem[32'h100 >> 2]
            );
            errors = errors + 1;
        end

        // ========================================================
        // UART TX
        // ========================================================

        $display("");
        $display("---------------- UART TX ----------------");

        if (dut.uart_tx_busy == 1'b0) begin

    $display("PASS: UART TX peripheral completed transmission");

end
else begin

    $display("FAIL: UART TX peripheral still busy");

    errors = errors + 1;

end

        // ========================================================
        // CONTROL REGISTER
        // ========================================================

        $display("");
        $display("---------------- CONTROL ----------------");

        if (dut.uart_rx_interrupt_enable == 1'b1) begin

            $display("PASS: UART RX interrupt enable");

        end
        else begin

            $display("FAIL: UART RX interrupt enable");

            errors = errors + 1;

        end

        // ========================================================
        // CSR
        // ========================================================

        $display("");
        $display("---------------- CSR ----------------");

        if (dut.core.csr_unit.mtvec == 32'h00000100) begin

            $display("PASS: MTVEC configured");

        end
        else begin

            $display(
                "FAIL: MTVEC = 0x%08h",
                dut.core.csr_unit.mtvec
            );

            errors = errors + 1;

        end

        // --------------------------------------------------------
        // MSTATUS
        // --------------------------------------------------------

        $display(
            "MSTATUS = 0x%08h",
            dut.core.csr_unit.mstatus
        );

        // ========================================================
        // TRAP
        // ========================================================

        $display("");
        $display("---------------- TRAP / ECALL ----------------");

        if (dut.core.registers.registers[21] ==
            32'h0000000B) begin

            $display(
                "PASS: ECALL MCAUSE = 11"
            );

        end
        else begin

            $display(
                "FAIL: MCAUSE = 0x%08h",
                dut.core.registers.registers[21]
            );

            errors = errors + 1;

        end

        // ========================================================
        // PERFORMANCE COUNTERS
        // ========================================================

        $display("");
        $display("---------------- PERFORMANCE ----------------");

        $display(
            "CYCLE   = 0x%016h",
            dut.core.cycle_count
        );

        $display(
            "INSTRET = 0x%016h",
            dut.core.instret_count
        );

        $display(
            "STALL   = 0x%016h",
            dut.core.stall_count
        );

        if (dut.core.cycle_count > 64'd0) begin

            $display("PASS: 64-bit cycle counter active");

        end
        else begin

            $display("FAIL: Cycle counter did not increment");

            errors = errors + 1;

        end

        if (dut.core.instret_count > 64'd0) begin

            $display("PASS: 64-bit instret counter active");

        end
        else begin

            $display("FAIL: Instret counter did not increment");

            errors = errors + 1;

        end

        // ========================================================
        // UART RX INTERRUPT STATE
        // ========================================================

        $display("");
        $display("---------------- UART RX ----------------");

        // Drive UART RX activity.
        //
        // The RX peripheral is configured with CLKS_PER_BIT = 4.
        //
        // Send a start bit followed by 8 data bits and stop bit.
        //
        // Byte = 0x5A
        //
        // LSB first.
        // ========================================================

        uart_rx = 1'b1;

        // idle
        wait_cycles(5);

        // start bit
        uart_rx = 1'b0;
        wait_cycles(4);

        // bit 0 = 0
        uart_rx = 1'b0;
        wait_cycles(4);

        // bit 1 = 1
        uart_rx = 1'b1;
        wait_cycles(4);

        // bit 2 = 0
        uart_rx = 1'b0;
        wait_cycles(4);

        // bit 3 = 1
        uart_rx = 1'b1;
        wait_cycles(4);

        // bit 4 = 1
        uart_rx = 1'b1;
        wait_cycles(4);

        // bit 5 = 0
        uart_rx = 1'b0;
        wait_cycles(4);

        // bit 6 = 1
        uart_rx = 1'b1;
        wait_cycles(4);

        // bit 7 = 0
        uart_rx = 1'b0;
        wait_cycles(4);

        // stop
        uart_rx = 1'b1;
        wait_cycles(6);

        // --------------------------------------------------------
        // Check received byte
        // --------------------------------------------------------

        if (dut.uart_rx_peripheral.rx_data ==
            8'h5A) begin

            $display(
                "PASS: UART RX received 0x5A"
            );

        end
        else begin

            $display(
                "FAIL: UART RX data = 0x%02h",
                dut.uart_rx_peripheral.rx_data
            );

            errors = errors + 1;

        end

        // ========================================================
        // FINAL INTERRUPT / CSR STATE
        // ========================================================

        $display("");
        $display("---------------- FINAL CSR STATE ----------------");

        $display(
            "MSTATUS = 0x%08h",
            dut.core.csr_unit.mstatus
        );

        $display(
            "MIE     = 0x%08h",
            dut.core.csr_unit.mie
        );

        $display(
            "MCAUSE  = 0x%08h",
            dut.core.csr_unit.mcause
        );

        $display(
            "MEPC    = 0x%08h",
            dut.core.csr_unit.mepc
        );

        $display(
            "MTVEC   = 0x%08h",
            dut.core.csr_unit.mtvec
        );

        // ========================================================
        // FINAL REGISTER STATE
        // ========================================================

        $display("");
        $display("---------------- FINAL CPU STATE ----------------");

        $display(
            "x5  = 0x%08h",
            dut.core.registers.registers[5]
        );

        $display(
            "x17 = 0x%08h",
            dut.core.registers.registers[17]
        );

        $display(
            "x20 = 0x%08h",
            dut.core.registers.registers[20]
        );

        $display(
            "x21 = 0x%08h",
            dut.core.registers.registers[21]
        );

        $display(
            "x22 = 0x%08h",
            dut.core.registers.registers[22]
        );

        $display(
            "x23 = 0x%08h",
            dut.core.registers.registers[23]
        );

        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display(
                "       STAGE 6 FULL SOC REGRESSION PASS"
            );

            $display("");
            $display(
                "       RV32I CPU + CSR + TRAP + IRQ"
            );

            $display(
                "       + PERFORMANCE COUNTERS"
            );

            $display(
                "       + RAM + GPIO + UART TX/RX"
            );

            $display(
                "       + MMIO + INTERRUPT PRIORITY"
            );

            $display(
                "       + MRET + ECALL"
            );

            $display("");
            $display(
                "       PROJECT FINAL REGRESSION PASS"
            );

        end
        else begin

            $display(
                "       STAGE 6 FULL SOC REGRESSION FAIL"
            );

            $display(
                "       ERROR COUNT = %0d",
                errors
            );

        end

        $display("======================================================");
        $display("");

        $finish;

    end

endmodule