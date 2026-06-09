// ============================================================
// Módulo: Estágio WB (Write Back)
// Função: Selecionar qual dado será escrito no registrador
// Opções: Resultado da ULA, dado da memória, ou PC+4
// ============================================================

module wb_stage(
    input  wire [31:0] alu_result,    // Resultado da ULA
    input  wire [31:0] mem_read_data, // Dado lido da memória
    input  wire [31:0] pc_plus_4,     // PC+4 (para JAL/JALR)
    input  wire        mem_to_reg,    // Seleciona memória (1) ou ULA (0)
    input  wire        jump,          // É instrução de jump? (JAL/JALR)
    input  wire [31:0] lui_imm,       // Imediato do LUI (já shiftado)
    input  wire        is_lui,        // É instrução LUI?
    output wire [31:0] write_data     // Dado final a ser escrito
);
    
    // ===== MULTIPLEXADORES EM CASCATA =====
    // 1. Escolhe entre ULA e Memória
    wire [31:0] alu_or_mem;
    assign alu_or_mem = mem_to_reg ? mem_read_data : alu_result;
    
    // 2. Escolhe entre ULA/Memória e PC+4 (para jump)
    wire [31:0] with_jump;
    assign with_jump = jump ? pc_plus_4 : alu_or_mem;
    
    // 3. Escolhe entre o anterior e o imediato do LUI
    assign write_data = is_lui ? lui_imm : with_jump;

endmodule