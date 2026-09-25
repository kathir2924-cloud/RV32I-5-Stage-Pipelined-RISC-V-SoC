[1mdiff --git a/rtl/riscv_core.v b/rtl/riscv_core.v[m
[1mindex 29d24d9..a3c26d4 100644[m
[1m--- a/rtl/riscv_core.v[m
[1m+++ b/rtl/riscv_core.v[m
[36m@@ -7,11 +7,24 @@[m [mmodule riscv_core #([m
     parameter MMIO_TEST              = 1'b0,[m
     parameter UART_TX_TEST           = 1'b0,[m
     parameter UART_RX_TEST           = 1'b0,[m
[31m-    parameter UART_RX_INTERRUPT_TEST = 1'b0[m
[31m-) ([m
[31m-    input wire clk,[m
[32m+[m[32m    parameter UART_RX_INTERRUPT_TEST = 1'b0,[m
[32m+[m[32m    parameter SOC_MODE = 1'b0[m
[32m+[m[32m)   ( input wire clk,[m
     input wire rst,[m
[31m-    input wire uart_rx[m
[32m+[m[32m    input wire uart_rx,[m
[32m+[m
[32m+[m[32m    // ============================================================[m
[32m+[m[32m    // SOC EXTERNAL MEMORY INTERFACE[m
[32m+[m[32m    // ============================================================[m
[32m+[m
[32m+[m[32m    output wire [31:0] imem_addr,[m
[32m+[m[32m    input  wire [31:0] imem_rdata,[m
[32m+[m
[32m+[m[32m    output wire        dmem_read,[m
[32m+[m[32m    output wire        dmem_write,[m
[32m+[m[32m    output wire [31:0] dmem_addr,[m
[32m+[m[32m    output wire [31:0] dmem_wdata,[m
[32m+[m[32m    input  wire [31:0] dmem_rdata[m
 );[m
     // ============================================================[m
     // IF STAGE[m
[36m@@ -19,6 +32,8 @@[m [mmodule riscv_core #([m
 [m
     wire [31:0] pc;[m
     wire [31:0] instruction;[m
[32m+[m[32m    // External instruction memory address[m
[32m+[m[32massign imem_addr = pc;[m
 [m
     wire pc_write;[m
     wire pc_write_final;[m
[36m@@ -134,69 +149,51 @@[m [massign pc_write_final =[m
 // ============================================================[m
 [m
 generate[m
[31m-[m
[31m-    if (CSR_TEST == 1'b1) begin : GEN_CSR_TEST_IMEM[m
[31m-[m
[32m+[m[32m    if (SOC_MODE == 1'b1) begin : GEN_SOC_IMEM[m
[32m+[m[32m        assign instruction = imem_rdata;[m
[32m+[m[32m    end[m
[32m+[m[32m    else if (CSR_TEST == 1'b1) begin : GEN_CSR_TEST_IMEM[m
         csr_test_instruction_memory csr_test_imem ([m
             .address(pc),[m
             .instruction(instruction)[m
         );[m
     end[m
[31m-[m
     else if (TIMER_TEST == 1'b1) begin : GEN_TIMER_TEST_IMEM[m
[31m-[m
         timer_interrupt_instruction_memory timer_test_imem ([m
             .address(pc),[m
             .instruction(instruction)[m
         );[m
[31m-[m
     end[m
[31m-[m
     else if (MMIO_TEST == 1'b1) begin : GEN_MMIO_TEST_IMEM[m
[31m-[m
         mmio_test_instruction_memory mmio_test_imem ([m
             .address(pc),[m
             .instruction(instruction)[m
         );[m
[31m-[m
     end[m
[31m-[m
     else if (UART_TX_TEST == 1'b1) begin : GEN_UART_TX_TEST_IMEM[m
[31m-[m
         mmio_uart_tx_test_instruction_memory uart_tx_test_imem ([m
             .address(pc),[m
             .instruction(instruction)[m
         );[m
[31m-[m
     end[m
[31m-[m
     else if (UART_RX_INTERRUPT_TEST == 1'b1) begin : GEN_UART_RX_INTERRUPT_TEST_IMEM[m
[31m-[m
         uart_rx_interrupt_test_instruction_memory uart_rx_interrupt_test_imem ([m
             .address(pc),[m
             .instruction(instruction)[m
         );[m
[31m-[m
     end[m
[31m-[m
     else if (UART_RX_TEST == 1'b1) begin : GEN_UART_RX_TEST_IMEM[m
[31m-[m
         mmio_uart_rx_test_instruction_memory uart_rx_test_imem ([m
             .address(pc),[m
             .instruction(instruction)[m
         );[m
[31m-[m
     end[m
[31m-[m
     else begin : GEN_TRAP_TEST_IMEM[m
[31m-[m
         trap_test_instruction_memory trap_test_imem ([m
             .address(pc),[m
             .instruction(instruction)[m
         );[m
[31m-[m
     end[m
[31m-[m
 endgenerate [m
 [m
 [m
[36m@@ -1062,6 +1059,18 @@[m [malu processor_alu ([m
     wire mem_mem_to_reg;[m
     wire mem_jump;[m
     wire mem_valid;[m
[32m+[m[32m    assign dmem_addr  = mem_alu_result;[m
[32m+[m[32massign dmem_wdata = mem_read_data2;[m
[32m+[m
[32m+[m[32massign dmem_read =[m
[32m+[m[32m    SOC_MODE &&[m
[32m+[m[32m    mem_mem_read &&[m
[32m+[m[32m    !mmio_read;[m
[32m+[m
[32m+[m[32massign dmem_write =[m
[32m+[m[32m    SOC_MODE &&[m
[32m+[m[32m    mem_mem_write &&[m
[32m+[m[32m    !mmio_write;[m
     // ============================================================[m
 // RESULT SENT TO EX/MEM[m
 // ============================================================[m
[36m@@ -1217,14 +1226,10 @@[m [massign uart_rx_interrupt_clear =[m
 [m
     data_memory dmem ([m
     .clk(clk),[m
[31m-[m
     .mem_read(mem_mem_read && !mmio_read),[m
     .mem_write(mem_mem_write && !mmio_write),[m
[31m-[m
     .address(mem_alu_result),[m
[31m-[m
     .write_data(mem_read_data2),[m
[31m-[m
     .read_data(memory_data)[m
 );[m
 [m
