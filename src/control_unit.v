// ============================================================
// Módulo: Unidade de Controle Principal (Control Unit)
// Função: Gera TODOS os sinais de controle do processador
// Tipo: Módulo COMBINACIONAL (always @*)
// Baseado APENAS no opcode da instrução
// ============================================================

module control_unit(
    input  wire [6:0] opcode,       // Opcode da instrução (7 bits)
    output reg        reg_write,    // Escrever no banco de registradores?
    output reg        alu_src,      // Usar imediato (1) ou rs2 (0)?
    output reg        mem_read,     // Ler da memória de dados?
    output reg        mem_write,    // Escrever na memória de dados?
    output reg        branch,       // É instrução de branch?
    output reg        jump,         // É instrução de jump?
    output reg        mem_to_reg,   // Dado do WB vem da memória?
    output reg  [1:0] alu_op        // Tipo de operação da ULA
);
    
    always @(*) begin
        // ===== VALORES DEFAULT (tudo zero) =====
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        mem_to_reg = 1'b0;
        alu_op     = 2'b00;
        
        // ===== DECODIFICAÇÃO POR OPCODE =====
        case(opcode)
            // R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            7'b0110011: begin
                reg_write = 1'b1;   // Escreve resultado no registrador
                alu_op    = 2'b10;  // ULA control decide operação
            end
            
            // I-type aritmético: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011: begin
                reg_write = 1'b1;   // Escreve resultado no registrador
                alu_src   = 1'b1;   // Usa imediato como operando B
                alu_op    = 2'b11;  // ULA control decide operação I-type
            end
            
            // I-type load: LW
            7'b0000011: begin
                reg_write  = 1'b1;   // Escreve dado lido no registrador
                alu_src    = 1'b1;   // Usa imediato para endereço
                mem_read   = 1'b1;   // Habilita leitura da memória
                mem_to_reg = 1'b1;   // Dado vem da memória (não da ULA)
                alu_op     = 2'b00;  // ULA faz ADD (endereço = rs1 + imm)
            end
            
            // S-type store: SW
            7'b0100011: begin
                alu_src   = 1'b1;   // Usa imediato para endereço
                mem_write = 1'b1;   // Habilita escrita na memória
                alu_op    = 2'b00;  // ULA faz ADD (endereço = rs1 + imm)
                // NÃO escreve no registrador (reg_write = 0)
            end
            
            // B-type branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                branch  = 1'b1;     // É um branch condicional
                alu_op  = 2'b01;    // ULA faz SUB para comparar
                // NÃO escreve no registrador
            end
            
            // J-type: JAL
            7'b1101111: begin
                reg_write = 1'b1;   // Escreve PC+4 no registrador (retorno)
                jump      = 1'b1;   // Salto incondicional
                // alu_op não importa, usa somador de jump
            end
            
            // I-type: JALR
            7'b1100111: begin
                reg_write = 1'b1;   // Escreve PC+4 no registrador (retorno)
                alu_src   = 1'b1;   // Usa imediato
                jump      = 1'b1;   // Salto incondicional
            end
            
            // U-type: LUI
            7'b0110111: begin
                reg_write = 1'b1;   // Escreve imediato no registrador
                // Tratamento especial no datapath (não passa pela ULA)
            end
            
            // Default: nenhum sinal ativo
            default: begin
                // Mantém todos os sinais em zero
            end
        endcase
    end

endmodule