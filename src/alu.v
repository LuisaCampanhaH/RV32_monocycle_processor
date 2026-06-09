// ============================================================
// Módulo: Unidade Lógica e Aritmética (ULA/ALU)
// Função: Executa operações aritméticas e lógicas
// Entradas: Dois operandos de 32 bits + código de operação
// Saídas: Resultado de 32 bits + flag zero
// ============================================================

module alu(
    input  wire [31:0] a,          // Operando A
    input  wire [31:0] b,          // Operando B
    input  wire [3:0]  alu_ctrl,   // Código da operação (4 bits)
    output reg  [31:0] result,     // Resultado da operação
    output wire        zero        // Flag: resultado == 0?
);
    
    // Flag zero: indica se o resultado é zero
    assign zero = (result == 32'b0);
    
    // Lógica combinacional: sempre que entradas mudam, recalcula
    always @(*) begin
        case(alu_ctrl)
            4'b0010: result = a + b;                        // ADD  (soma)
            4'b0110: result = a - b;                        // SUB  (subtração)
            4'b0101: result = a << b[4:0];                  // SLL  (shift left logical)
            4'b0111: result = a >> b[4:0];                  // SRL  (shift right logical)
            4'b1100: result = $signed(a) >>> b[4:0];        // SRA  (shift right arithmetic)
            4'b0100: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;  // SLT  (set less than signed)
            4'b0011: result = (a < b) ? 32'd1 : 32'd0;      // SLTU (set less than unsigned)
            4'b1000: result = a ^ b;                        // XOR
            4'b1001: result = a | b;                        // OR
            4'b1010: result = a & b;                        // AND
            default: result = 32'b0;                        // Operação inválida = 0
        endcase
    end

endmodule