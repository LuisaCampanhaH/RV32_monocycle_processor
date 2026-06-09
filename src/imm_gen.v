// ============================================================
// Módulo: Gerador de Imediato (Immediate Generator)
// Função: Extrai o imediato da instrução de 32 bits
// Cada tipo de instrução (I, S, B, U, J) tem os bits do 
// imediato em posições diferentes - este módulo reorganiza
// ============================================================

module imm_gen(
    input  wire [31:0] instr,    // Instrução completa de 32 bits
    output reg  [31:0] imm       // Imediato extendido para 32 bits
);
    
    // Opcode está nos bits [6:0]
    wire [6:0] opcode = instr[6:0];
    
    always @(*) begin
        case(opcode)
            // ===== I-type: ADDI, SLLI, SRLI, SRAI, SLTI, SLTIU, XORI, ORI, ANDI, LW, JALR =====
            // Formato: imm[11:0] nos bits [31:20] da instrução
            7'b0010011,   // Tipo I aritmético
            7'b0000011,   // LW
            7'b1100111: begin // JALR
                // Estende o sinal: repete o bit 31 por 20 vezes + bits [31:20]
                imm = {{20{instr[31]}}, instr[31:20]};
            end
            
            // ===== S-type: SW =====
            // Formato: imm[11:5] em [31:25], imm[4:0] em [11:7]
            7'b0100011: begin
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            
            // ===== B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU =====
            // Formato: imm[12] em [31], imm[10:5] em [30:25], 
            //          imm[4:1] em [11:8], imm[11] em [7]
            // O bit 0 é sempre 0 (instruções alinhadas)
            7'b1100011: begin
                imm = {{19{instr[31]}}, instr[31], instr[7], 
                       instr[30:25], instr[11:8], 1'b0};
            end
            
            // ===== U-type: LUI =====
            // Formato: imm[31:12] em [31:12], bits inferiores são zero
            7'b0110111: begin
                imm = {instr[31:12], 12'b0};
            end
            
            // ===== J-type: JAL =====
            // Formato: imm[20] em [31], imm[10:1] em [30:21], 
            //          imm[11] em [20], imm[19:12] em [19:12]
            // O bit 0 é sempre 0
            7'b1101111: begin
                imm = {{11{instr[31]}}, instr[31], instr[19:12], 
                       instr[20], instr[30:21], 1'b0};
            end
            
            // Opcode desconhecido
            default: begin
                imm = 32'b0;
            end
        endcase
    end

endmodule