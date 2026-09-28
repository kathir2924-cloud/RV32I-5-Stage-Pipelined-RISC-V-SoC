`timescale 1ns/1ps

module riscv_interrupt_handler_mret_tb;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    reg clk;
    reg rst;
    reg uart_rx;

    integer errors;
    integer i;


    // ============================================================
    // CPU INTERFACE
    // ============================================================

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


    // ============================================================
    // SIMPLE TESTBENCH MEMORY
    // ============================================================

    reg [31:0] memory [0:1023];


    // ============================================================
    // DUT
    //
    // SOC_MODE = 1
    //
    // This forces the CPU to use the external instruction/data
    // interfaces supplied by this testbench.
    // ============================================================

    riscv_core #(
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
    // INSTRUCTION MEMORY
    // ============================================================

    always @(*) begin

        if (imem_addr[31:2] < 1024)

            imem_rdata = memory[imem_addr[31:2]];

        else

            imem_rdata = 32'h00000013;

    end


    // ============================================================
    // DATA MEMORY
    // ============================================================

    always @(*) begin

        dmem_rdata = 32'b0;

        if (dmem_read) begin

            if (dmem_addr[31:2] < 1024)

                dmem_rdata = memory[dmem_addr[31:2]];

        end

    end


    always @(posedge clk) begin

        if (dmem_write) begin

            if (dmem_addr[31:2] < 1024)

                memory[dmem_addr[31:2]] <= dmem_wdata;

        end

    end


    // ============================================================
    // MMIO
    //
    // Addresses used by current design:
    //
    // GPIO     = 0x10000000
    // UART TX  = 0x10000004
    // UART RX  = 0x10000008
    // STATUS   = 0x10000010
    // CONTROL  = 0x10000014
    // ============================================================

    always @(*) begin

        mmio_rdata = 32'b0;

        case (mmio_addr)

            32'h10000000:
                mmio_rdata = 32'b0;

            32'h10000008:
                mmio_rdata = 32'h00000055;

            32'h10000010:
                mmio_rdata = 32'b0;

            32'h10000014:
                mmio_rdata = 32'h00000001;

            default:
                mmio_rdata = 32'b0;

        endcase

    end


    // ============================================================
    // UART RX
    //
    // This test uses the actual CPU interrupt input path.
    //
    // We generate a UART frame later.
    // ============================================================

    task uart_send_byte;

        input [7:0] data;

        integer b;

        begin

            // START

            uart_rx = 1'b0;

            repeat (4)
                @(posedge clk);


            // DATA

            for (b = 0; b < 8; b = b + 1) begin

                uart_rx = data[b];

                repeat (4)
                    @(posedge clk);

            end


            // STOP

            uart_rx = 1'b1;

            repeat (4)
                @(posedge clk);

        end

    endtask


    // ============================================================
    // RV32I ENCODERS
    // ============================================================

    function [31:0] enc_lui;

        input [4:0] rd;
        input [19:0] imm;

        begin

            enc_lui =
                {imm, rd, 7'b0110111};

        end

    endfunction


    function [31:0] enc_addi;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;

        begin

            enc_addi =
                {imm, rs1, 3'b000, rd, 7'b0010011};

        end

    endfunction


    function [31:0] enc_sw;

        input [4:0] rs2;
        input [4:0] rs1;
        input [11:0] imm;

        begin

            enc_sw =
                {
                    imm[11:5],
                    rs2,
                    rs1,
                    3'b010,
                    imm[4:0],
                    7'b0100011
                };

        end

    endfunction


    function [31:0] enc_lw;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] imm;

        begin

            enc_lw =
                {imm, rs1, 3'b010, rd, 7'b0000011};

        end

    endfunction


    function [31:0] enc_csrrw;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] csr;

        begin

            enc_csrrw =
                {csr, rs1, 3'b001, rd, 7'b1110011};

        end

    endfunction


    function [31:0] enc_csrrs;

        input [4:0] rd;
        input [4:0] rs1;
        input [11:0] csr;

        begin

            enc_csrrs =
                {csr, rs1, 3'b010, rd, 7'b1110011};

        end

    endfunction


    function [31:0] enc_csrrsi;

        input [4:0] rd;
        input [4:0] zimm;
        input [11:0] csr;

        begin

            enc_csrrsi =
                {csr, zimm, 3'b110, rd, 7'b1110011};

        end

    endfunction


    function [31:0] enc_csrrci;

        input [4:0] rd;
        input [4:0] zimm;
        input [11:0] csr;

        begin

            enc_csrrci =
                {csr, zimm, 3'b111, rd, 7'b1110011};

        end

    endfunction


    function [31:0] enc_mret;

        begin

            enc_mret = 32'h30200073;

        end

    endfunction


    // ============================================================
    // BRANCH
    //
    // BEQ rs1,rs2,offset
    // ============================================================

    function [31:0] enc_beq;

        input [4:0] rs1;
        input [4:0] rs2;
        input integer offset;

        reg [12:0] imm;

        begin

            imm = offset;

            enc_beq =
                {
                    imm[12],
                    imm[10:5],
                    rs2,
                    rs1,
                    3'b000,
                    imm[4:1],
                    imm[11],
                    1'b0,
                    7'b1100011
                };

        end

    endfunction


    // ============================================================
    // JAL
    // ============================================================

    function [31:0] enc_jal;

        input [4:0] rd;
        input integer offset;

        reg [20:0] imm;

        begin

            imm = offset;

            enc_jal =
                {
                    imm[20],
                    imm[10:1],
                    imm[11],
                    imm[19:12],
                    rd,
                    7'b1101111
                };

        end

    endfunction


    // ============================================================
    // INITIALIZE MEMORY
    // ============================================================

    initial begin

        errors = 0;

        uart_rx = 1'b1;

        rst = 1'b1;


        for (i = 0; i < 1024; i = i + 1)

            memory[i] = 32'h00000013;


        // ========================================================
        // MAIN PROGRAM
        //
        // Address 0x0000
        // ========================================================

        // x5 = 0x00000080
        //
        // MTVEC = 0x80

        memory[0] =
            enc_addi(
                5,
                0,
                12'h080
            );


        // CSRRW x0, x5, MTVEC

        memory[1] =
            enc_csrrw(
                0,
                5,
                12'h305
            );


        // Enable UART external interrupt:
        //
        // x6 = 0x800
        //
        // MIE bit 11

        memory[2] =
            enc_addi(
                6,
                0,
                12'h800
            );


        // CSRRW x0,x6,MIE

        memory[3] =
            enc_csrrw(
                0,
                6,
                12'h304
            );


        // Enable global MIE:
        //
        // x7 = 8
        //
        // MSTATUS.MIE

        memory[4] =
            enc_addi(
                7,
                0,
                12'h008
            );


        // CSRRS x0,x7,MSTATUS

        memory[5] =
            enc_csrrs(
                0,
                7,
                12'h300
            );


        // Enable UART interrupt through CONTROL MMIO
        //
        // x8 = 0x10000000

        memory[6] =
            enc_lui(
                8,
                20'h10000
            );


        // x9 = 1

        memory[7] =
            enc_addi(
                9,
                0,
                12'h001
            );


        // SW x9,20(x8)
        //
        // CONTROL = 1

        memory[8] =
            enc_sw(
                9,
                8,
                12'h014
            );


        // Normal execution marker:
        //
        // x10 = 0x11

        memory[9] =
            enc_addi(
                10,
                0,
                12'h011
            );


        // x11 = 0x22

        memory[10] =
            enc_addi(
                11,
                0,
                12'h022
            );


        // x12 = 0x33

        memory[11] =
            enc_addi(
                12,
                0,
                12'h033
            );


        // Loop
        //
        // This gives us a stable interrupted program.

        memory[12] =
            enc_beq(
                0,
                0,
                0
            );


        // ========================================================
        // INTERRUPT HANDLER
        //
        // 0x80 / 4 = 32
        //
        // Handler:
        //
        // Read MCAUSE
        // Save it to memory[100]
        //
        // Read MEPC
        // Save it to memory[101]
        //
        // Read UART RX
        // Save received value to memory[102]
        //
        // Clear UART pending through UART RX read
        //
        // MRET
        // ========================================================

        // 0x80:
        // CSRR x13,MCAUSE
        //
        // CSRRS x13,x0,MCAUSE

        memory[32] =
            enc_csrrs(
                13,
                0,
                12'h342
            );


        // x14 = 400
        //
        // memory index 100

        memory[33] =
            enc_addi(
                14,
                0,
                12'h190
            );


        // SW x13,0(x14)

        memory[34] =
            enc_sw(
                13,
                14,
                12'h000
            );


        // CSRR x15,MEPC

        memory[35] =
            enc_csrrs(
                15,
                0,
                12'h341
            );


        // SW x15,4(x14)

        memory[36] =
            enc_sw(
                15,
                14,
                12'h004
            );


        // UART RX address:
        //
        // x16 = 0x10000000

        memory[37] =
            enc_lui(
                16,
                20'h10000
            );


        // LW x17,8(x16)

        memory[38] =
            enc_lw(
                17,
                16,
                12'h008
            );


        // SW x17,8(x14)

        memory[39] =
            enc_sw(
                17,
                14,
                12'h008
            );


        // MRET

        memory[40] =
            enc_mret();


        // ========================================================
        // PAD
        // ========================================================

        for (i = 41; i < 1024; i = i + 1) begin

            if (memory[i] === 32'hxxxxxxxx)

                memory[i] = 32'h00000013;

        end

    end


    // ============================================================
    // RESET
    // ============================================================

    initial begin

        repeat (8)
            @(posedge clk);

        rst = 1'b0;

        $display("");
        $display("======================================================");
        $display("     INTERRUPT HANDLER + MRET REGRESSION");
        $display("======================================================");
        $display("");

        $display("Reset released");

    end


    // ============================================================
    // UART EVENT
    //
    // Give software enough time to:
    //
    // 1. Set MTVEC
    // 2. Set MIE
    // 3. Set MSTATUS.MIE
    // 4. Enable UART interrupt
    //
    // Then send 0x55.
    // ============================================================

    initial begin

        wait (rst == 1'b0);

        repeat (35)
            @(posedge clk);


        $display("");
        $display("[UART] Sending byte 0x55");

        uart_send_byte(8'h55);

        $display("[UART] Byte transmission complete");

    end


    // ============================================================
    // MONITOR INTERRUPT
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            if (dut.interrupt_taken) begin

                $display(
                    "INTERRUPT TAKEN: PC=0x%08h CAUSE=0x%08h",
                    dut.pc,
                    dut.interrupt_cause
                );

            end


            if (dut.trap_taken) begin

                $display(
                    "TRAP TAKEN: PC=0x%08h CAUSE=0x%08h",
                    dut.pc,
                    dut.ex_trap_cause
                );

            end


            if (dut.mret_taken) begin

                $display(
                    "MRET TAKEN: return PC=0x%08h",
                    dut.mepc_value
                );

            end

        end

    end


    // ============================================================
    // FINAL CHECKS
    // ============================================================

    initial begin

        wait (rst == 1'b0);


        // Allow UART interrupt + handler + MRET

        repeat (180)
            @(posedge clk);


        $display("");
        $display("======================================================");
        $display("                 REGRESSION RESULTS");
        $display("======================================================");


        // --------------------------------------------------------
        // MCAUSE
        // --------------------------------------------------------

        $display(
            "Stored MCAUSE = 0x%08h",
            memory[100]
        );

        if (memory[100] == 32'h8000000B) begin

            $display(
                "PASS: UART external interrupt cause"
            );

        end
        else begin

            $display(
                "FAIL: Expected 0x8000000B"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MEPC
        // --------------------------------------------------------

        $display(
            "Stored MEPC   = 0x%08h",
            memory[101]
        );

        if (memory[101] != 32'h00000000) begin

            $display(
                "PASS: Precise interrupt MEPC captured"
            );

        end
        else begin

            $display(
                "FAIL: MEPC was zero"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // UART DATA
        // --------------------------------------------------------

        $display(
            "Stored UART RX = 0x%08h",
            memory[102]
        );

        if (memory[102] == 32'h00000055) begin

            $display(
                "PASS: Software handler received UART byte"
            );

        end
        else begin

            $display(
                "FAIL: UART handler data incorrect"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // NORMAL PROGRAM RESUMPTION
        // --------------------------------------------------------

        $display(
            "x10 = 0x%08h",
            dut.registers.registers[10]
        );

        $display(
            "x11 = 0x%08h",
            dut.registers.registers[11]
        );

        $display(
            "x12 = 0x%08h",
            dut.registers.registers[12]
        );


        if (
            dut.registers.registers[10] == 32'h11 &&
            dut.registers.registers[11] == 32'h22 &&
            dut.registers.registers[12] == 32'h33
        ) begin

            $display(
                "PASS: Normal program resumed after MRET"
            );

        end
        else begin

            $display(
                "FAIL: Normal program did not resume"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MTVEC
        // --------------------------------------------------------

        if (dut.csr_unit.mtvec == 32'h00000080) begin

            $display(
                "PASS: MTVEC = 0x00000080"
            );

        end
        else begin

            $display(
                "FAIL: MTVEC = 0x%08h",
                dut.csr_unit.mtvec
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // MIE
        // --------------------------------------------------------

        if (dut.csr_unit.mie[11] == 1'b1) begin

            $display(
                "PASS: MIE.MEIE enabled"
            );

        end
        else begin

            $display(
                "FAIL: MIE.MEIE disabled"
            );

            errors = errors + 1;

        end


        // --------------------------------------------------------
        // PERFORMANCE
        // --------------------------------------------------------

        $display(
            "CYCLE   = 0x%016h",
            dut.cycle_count
        );

        $display(
            "INSTRET = 0x%016h",
            dut.instret_count
        );


        // --------------------------------------------------------
        // FINAL
        // --------------------------------------------------------

        $display("");
        $display("======================================================");

        if (errors == 0) begin

            $display(
                "       INTERRUPT + MRET REGRESSION PASS"
            );

        end
        else begin

            $display(
                "       INTERRUPT + MRET REGRESSION FAIL"
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