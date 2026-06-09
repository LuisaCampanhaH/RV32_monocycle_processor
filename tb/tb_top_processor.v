// ============================================================
// Testbench do Processador RV32I Monociclo
// Função: Carregar programa, estimular clock, verificar execução
// ============================================================

`timescale 1ns / 1ps

module tb_top_processor;
    
    // ===== SINAIS DE TESTE =====
    reg clk;
    reg reset;
    
    // ===== INSTANCIAR O PROCESSADOR =====
    top_processor uut(
        .clk(clk),
        .reset(reset)
    );
    
    // ===== GERADOR DE CLOCK (período = 10ns = 100MHz) =====
    always #5 clk = ~clk;
    
    // ===== BLOCO PRINCIPAL DE TESTE =====
    initial begin
        // Inicializar sinais
        clk = 0;
        reset = 1;
        
        // ===== CARREGAR PROGRAMA NA MEMÓRIA DE INSTRUÇÕES =====
        // Programa que testa TODAS as 30 instruções RV32I
        $readmemh("../programs/test_all_instr.hex", uut.if_stage_inst.instr_mem);
        
        // ===== INICIAR SIMULAÇÃO =====
        #10 reset = 0;  // Liberar reset após 10ns
        
        // ===== EXECUTAR POR VÁRIOS CICLOS =====
        #500;  // Esperar 50 ciclos de clock
        
        // ===== VERIFICAR RESULTADOS =====
        $display("===========================================");
        $display("    RESULTADOS DA SIMULAÇÃO RV32I");
        $display("===========================================");
        $display("x1  (LUI)    = 0x%h", uut.id_stage_inst.reg_file_inst.registers[1]);
        $display("x2  (ADDI)   = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[2], 
                                               uut.id_stage_inst.reg_file_inst.registers[2]);
        $display("x3  (SLTI)   = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[3], 
                                               uut.id_stage_inst.reg_file_inst.registers[3]);
        $display("x4  (SLTIU)  = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[4], 
                                               uut.id_stage_inst.reg_file_inst.registers[4]);
        $display("x5  (XORI)   = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[5], 
                                               uut.id_stage_inst.reg_file_inst.registers[5]);
        $display("x6  (ORI)    = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[6], 
                                               uut.id_stage_inst.reg_file_inst.registers[6]);
        $display("x7  (ANDI)   = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[7], 
                                               uut.id_stage_inst.reg_file_inst.registers[7]);
        $display("x8  (SLLI)   = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[8], 
                                               uut.id_stage_inst.reg_file_inst.registers[8]);
        $display("x9  (SRLI)   = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[9], 
                                               uut.id_stage_inst.reg_file_inst.registers[9]);
        $display("x10 (SRAI)   = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[10], 
                                               uut.id_stage_inst.reg_file_inst.registers[10]);
        $display("x11 (ADD)    = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[11], 
                                               uut.id_stage_inst.reg_file_inst.registers[11]);
        $display("x12 (SUB)    = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[12], 
                                               uut.id_stage_inst.reg_file_inst.registers[12]);
        $display("x19 (OR)     = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[19], 
                                               uut.id_stage_inst.reg_file_inst.registers[19]);
        $display("x20 (AND)    = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[20], 
                                               uut.id_stage_inst.reg_file_inst.registers[20]);
        $display("x23 (LW)     = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[23], 
                                               uut.id_stage_inst.reg_file_inst.registers[23]);
        $display("x26 (Branch) = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[26], 
                                               uut.id_stage_inst.reg_file_inst.registers[26]);
        $display("x27 (Branch) = 0x%h (%0d)", uut.id_stage_inst.reg_file_inst.registers[27], 
                                               uut.id_stage_inst.reg_file_inst.registers[27]);
        $display("x29 (JAL)    = 0x%h", uut.id_stage_inst.reg_file_inst.registers[29]);
        $display("x31 (Fim)    = 0x%h", uut.id_stage_inst.reg_file_inst.registers[31]);
        $display("===========================================");
        
        // ===== FINALIZAR SIMULAÇÃO =====
        $display("Simulação concluída com sucesso!");
        $finish;
    end
    
    // ===== GERAR ARQUIVO DE FORMA DE ONDA =====
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_top_processor);
    end

endmodule