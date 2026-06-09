// ============================================================
// Módulo: Controle da ULA (ALU Control)
// Função: Decodifica os sinais para gerar o código da ULA
// Entradas: alu_op (da unidade de controle), funct3, funct7[5]
// Saídas: alu_ctrl (código de 4 bits para a ULA)
// ============================================================

module alu_control(
    input  wire [1:0] alu_op,      // Vem da Unidade de Controle principal
    input  wire [2:0] funct3,      // Campo funct3 da instrução
    input  wire       funct7_5,    // Bit 30 da instrução (funct7[5])
    output reg  [3:0] alu_ctrl     // Código enviado para a ULA
);
    
    always @(*) begin
        case(alu_op)
            // LW, SW, ADDI: fazem soma
            2'b00: alu_ctrl = 4'b0010;   // ADD
            
            // Branches: fazem subtração para comparar
            2'b01: alu_ctrl = 4'b0110;   // SUB
            
            // R-type: operação definida por funct3 e funct7
            2'b10: begin
                case(funct3)
                    3'b000: alu_ctrl = funct7_5 ? 4'b0110 : 4'b0010; // SUB ou ADD
                    3'b001: alu_ctrl = 4'b0101; // SLL
                    3'b010: alu_ctrl = 4'b0100; // SLT
                    3'b011: alu_ctrl = 4'b0011; // SLTU
                    3'b100: alu_ctrl = 4'b1000; // XOR
                    3'b101: alu_ctrl = funct7_5 ? 4'b1100 : 4'b0111; // SRA ou SRL
                    3'b110: alu_ctrl = 4'b1001; // OR
                    3'b111: alu_ctrl = 4'b1010; // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            
            // I-type imediato: operação definida por funct3
            2'b11: begin
                case(funct3)
                    3'b000: alu_ctrl = 4'b0010; // ADDI
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b010: alu_ctrl = 4'b0100; // SLTI
                    3'b011: alu_ctrl = 4'b0011; // SLTIU
                    3'b100: alu_ctrl = 4'b1000; // XORI
                    3'b101: alu_ctrl = funct7_5 ? 4'b1100 : 4'b0111; // SRAI ou SRLI
                    3'b110: alu_ctrl = 4'b1001; // ORI
                    3'b111: alu_ctrl = 4'b1010; // ANDI
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule