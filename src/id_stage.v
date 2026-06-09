// ============================================================
// Módulo: Estágio ID (Instruction Decode)
// Função: Decodificar a instrução, ler registradores,
//         gerar imediato e sinais de controle
// Contém: Banco de Registradores, Imm-Gen, Unidade de Controle
// ============================================================

module id_stage(
    input  wire        clk,
    input  wire [31:0] instr,        // Instrução do estágio IF
    input  wire [31:0] write_data,   // Dado a escrever (do WB)
    input  wire [4:0]  rd_addr,      // Endereço destino (do WB)
    input  wire        reg_write,    // Sinal de escrita (do WB)
    
    // Saídas para o estágio EX
    output wire [31:0] rs1_data,     // Valor do registrador rs1
    output wire [31:0] rs2_data,     // Valor do registrador rs2
    output wire [31:0] imm,          // Imediato extendido
    
    // Sinais de controle gerados
    output wire        alu_src,
    output wire        mem_read,
    output wire        mem_write,
    output wire        branch,
    output wire        jump,
    output wire        mem_to_reg,
    output wire [1:0]  alu_op
);
    
    // ===== EXTRAIR CAMPOS DA INSTRUÇÃO =====
    wire [4:0] rs1_addr = instr[19:15];  // Registrador fonte 1
    wire [4:0] rs2_addr = instr[24:20];  // Registrador fonte 2
    wire [6:0] opcode   = instr[6:0];    // Opcode
    
    // ===== INSTANCIAR BANCO DE REGISTRADORES =====
    reg_file reg_file_inst(
        .clk(clk),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .write_data(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // ===== INSTANCIAR GERADOR DE IMEDIATO =====
    imm_gen imm_gen_inst(
        .instr(instr),
        .imm(imm)
    );
    
    // ===== INSTANCIAR UNIDADE DE CONTROLE =====
    control_unit control_unit_inst(
        .opcode(opcode),
        .reg_write(),       // Não usado aqui (vai para WB)
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op)
    );

endmodule