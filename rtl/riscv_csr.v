`timescale 1ns/1ps

module riscv_csr (

    input  wire        clk,
    input  wire        rst,

    // =========================================================
    // CSR ACCESS
    // =========================================================

    input  wire [11:0] csr_addr,
    output reg  [31:0] csr_rdata,

    input  wire        csr_write,
    input  wire [31:0] csr_wdata,

    // =========================================================
    // TRAP
    // =========================================================

    input  wire        trap_enter,
    input  wire [31:0] trap_pc,
    input  wire [31:0] trap_cause,
    input  wire [31:0] trap_value,

    // =========================================================
    // MRET
    // =========================================================

    input  wire        mret,

    // =========================================================
    // INTERRUPTS
    // =========================================================

    input  wire        timer_interrupt,
    input  wire        uart_rx_interrupt,

    // =========================================================
    // 64-BIT PERFORMANCE COUNTERS
    // =========================================================

    input  wire [63:0] cycle_count,
    input  wire [63:0] instret_count,

    // =========================================================
    // TRAP TARGETS
    // =========================================================

    output wire [31:0] mtvec_value,
    output wire [31:0] mepc_value,

    // =========================================================
    // INTERRUPT PENDING
    // =========================================================

    output wire        timer_interrupt_pending,
    output wire        uart_rx_interrupt_pending

);

    // =========================================================
    // MACHINE CSRs
    // =========================================================

    reg [31:0] mstatus;
    reg [31:0] mie;
    reg [31:0] mip;

    reg [31:0] mtvec;
    reg [31:0] mscratch;

    reg [31:0] mepc;
    reg [31:0] mcause;
    reg [31:0] mtval;

    // =========================================================
    // CSR ADDRESSES
    // =========================================================

    localparam [11:0] CSR_MSTATUS   = 12'h300;
    localparam [11:0] CSR_MIE       = 12'h304;
    localparam [11:0] CSR_MTVEC     = 12'h305;

    localparam [11:0] CSR_MSCRATCH  = 12'h340;
    localparam [11:0] CSR_MEPC      = 12'h341;
    localparam [11:0] CSR_MCAUSE    = 12'h342;
    localparam [11:0] CSR_MTVAL     = 12'h343;
    localparam [11:0] CSR_MIP       = 12'h344;

    // =========================================================
    // PERFORMANCE COUNTER CSR ADDRESSES
    // =========================================================

    localparam [11:0] CSR_CYCLE     = 12'hC00;
    localparam [11:0] CSR_TIME      = 12'hC01;
    localparam [11:0] CSR_INSTRET   = 12'hC02;

    localparam [11:0] CSR_CYCLEH    = 12'hC80;
    localparam [11:0] CSR_TIMEH     = 12'hC81;
    localparam [11:0] CSR_INSTRETH  = 12'hC82;

    // =========================================================
    // MIP
    // =========================================================

    always @(*) begin

        mip = 32'b0;

        // Machine Timer Interrupt Pending
        mip[7] = timer_interrupt;

        // Machine External Interrupt Pending
        // UART RX is currently the external source.
        mip[11] = uart_rx_interrupt;

    end

    // =========================================================
    // INTERRUPT PENDING
    // =========================================================

    assign timer_interrupt_pending =
        mstatus[3] &
        mie[7] &
        mip[7];

    assign uart_rx_interrupt_pending =
        mstatus[3] &
        mie[11] &
        mip[11];

    // =========================================================
    // CSR RESET / WRITE / TRAP / MRET
    // =========================================================

    always @(posedge clk) begin

        if (rst) begin

            mstatus <= 32'b0;
            mie     <= 32'b0;

            mtvec   <= 32'b0;
            mscratch <= 32'b0;

            mepc    <= 32'b0;
            mcause  <= 32'b0;
            mtval   <= 32'b0;

        end

        else begin

            // =================================================
            // NORMAL CSR WRITE
            // =================================================

            if (csr_write) begin

                case (csr_addr)

                    CSR_MSTATUS: begin
                        mstatus <= csr_wdata;
                    end

                    CSR_MIE: begin
                        mie <= csr_wdata;
                    end

                    CSR_MTVEC: begin
                        mtvec <= csr_wdata;
                    end

                    CSR_MSCRATCH: begin
                        mscratch <= csr_wdata;
                    end

                    CSR_MEPC: begin
                        mepc <= csr_wdata;
                    end

                    CSR_MCAUSE: begin
                        mcause <= csr_wdata;
                    end

                    CSR_MTVAL: begin
                        mtval <= csr_wdata;
                    end

                    default: begin
                        // Read-only or unsupported CSR.
                    end

                endcase

            end

            // =================================================
            // TRAP ENTRY
            // =================================================

            if (trap_enter) begin

                // Save faulting PC
                mepc <= trap_pc;

                // Save trap cause
                mcause <= trap_cause;

                // Save trap-specific value
                mtval <= trap_value;

                // MPIE <- MIE
                mstatus[7] <= mstatus[3];

                // MIE <- 0
                mstatus[3] <= 1'b0;

            end

            // =================================================
            // MRET
            // =================================================

            if (mret) begin

                // MIE <- MPIE
                mstatus[3] <= mstatus[7];

                // MPIE <- 1
                mstatus[7] <= 1'b1;

            end

        end

    end

    // =========================================================
    // CSR READ
    // =========================================================

    always @(*) begin

        // Safe default.
        csr_rdata = 32'b0;

        case (csr_addr)

            // -------------------------------------------------
            // MACHINE CSRs
            // -------------------------------------------------

            CSR_MSTATUS:
                csr_rdata = mstatus;

            CSR_MIE:
                csr_rdata = mie;

            CSR_MTVEC:
                csr_rdata = mtvec;

            CSR_MSCRATCH:
                csr_rdata = mscratch;

            CSR_MEPC:
                csr_rdata = mepc;

            CSR_MCAUSE:
                csr_rdata = mcause;

            CSR_MTVAL:
                csr_rdata = mtval;

            CSR_MIP:
                csr_rdata = mip;

            // -------------------------------------------------
            // 64-BIT PERFORMANCE COUNTERS
            // -------------------------------------------------

            // CYCLE low 32 bits
            CSR_CYCLE:
                csr_rdata = cycle_count[31:0];

            // TIME currently aliases the cycle counter
            // in this implementation.
            CSR_TIME:
                csr_rdata = cycle_count[31:0];

            // INSTRET low 32 bits
            CSR_INSTRET:
                csr_rdata = instret_count[31:0];

            // -------------------------------------------------
            // HIGH 32-BIT COUNTER CSRs
            // -------------------------------------------------

            // CYCLEH
            CSR_CYCLEH:
                csr_rdata = cycle_count[63:32];

            // TIMEH
            CSR_TIMEH:
                csr_rdata = cycle_count[63:32];

            // INSTRETH
            CSR_INSTRETH:
                csr_rdata = instret_count[63:32];

            // -------------------------------------------------
            // UNKNOWN CSR
            // -------------------------------------------------

            default:
                csr_rdata = 32'b0;

        endcase

    end

    // =========================================================
    // TRAP TARGETS
    // =========================================================

    assign mtvec_value = mtvec;
    assign mepc_value  = mepc;

endmodule