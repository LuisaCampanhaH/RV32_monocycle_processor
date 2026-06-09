// ============================================================
// Módulo: Estágio EX (Execute)
// Função: Executar a operação da ULA e calcular endereços
// Contém: ULA, Controle da ULA, multiplexador de operandos,
//         somador de branch
// ============================================================

module ex_stage(
    input  wire [31:0] rs1_data,     // Operando A (do registrador)
    input  wire [31:0] rs2_data,     // Operando B (do registrador)
    input  wire [31:0] imm,          // Imediato (alternativa para B)
    input  wire [31:0] pc,           // PC atual (para cálculo de branch)
    input  wire [1:0]  alu_op,       // Tipo de operação ULA
    input  wire [2:0]  funct3,       // Campo funct3 da instrução
    input  wire        funct7_5,     // Bit 30 da instrução
    input  wire        alu_src,      // Seleciona imediato (1) ou rs2 (0)
    
    output wire [31:0] alu_result,   // Resultado da ULA
    output wire        zero,         // Flag zero (resultado == 0)
    output wire [31:0] branch_target // Endereço alvo do branch
);
    
    // ===== MULTIPLEXADOR DO OPERANDO B =====
    // Se alu_src=1, usa o imediato; se 0, usa rs2_data
    wire [31:0] alu_b;
    assign alu_b = alu_src ? imm : rs2_data;
    
    // ===== INSTANCIAR CONTROLE DA ULA =====
    wire [3:0] alu_ctrl;
    alu_control alu_control_inst(
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_ctrl(alu_ctrl)
    );
    
    // ===== INSTANCIAR ULA =====
    alu alu_inst(
        .a(rs1_data),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );
    
    // ===== CÁLCULO DO ENDEREÇO DE BRANCH =====
    // Branch target = PC + (imediato << 1)
    // O imediato já vem com o bit 0 = 0 do imm_gen
    assign branch_target = pc + imm;

endmodule