// ============================================================
// Módulo: Estágio IF (Instruction Fetch)
// Função: Buscar a instrução da memória e calcular próximo PC
// Contém: PC, somador PC+4, memória de instruções, 
//         muxes para branch e jump
// ============================================================

module if_stage(
    input  wire        clk,           // Clock
    input  wire        reset,         // Reset (zera o PC)
    input  wire        branch_taken,  // Branch foi tomado?
    input  wire        jump,          // É instrução de jump?
    input  wire [31:0] branch_target, // Endereço alvo do branch
    input  wire [31:0] jump_target,   // Endereço alvo do jump
    output reg  [31:0] pc,            // Program Counter atual
    output wire [31:0] pc_plus_4,     // PC + 4 (próxima instrução)
    output wire [31:0] instr          // Instrução buscada da memória
);
    
    // ===== MEMÓRIA DE INSTRUÇÕES =====
    // 256 palavras de 32 bits (1 KB)
    reg [31:0] instr_mem [0:255];
    
    // ===== LÓGICA DO PRÓXIMO PC =====
    wire [31:0] next_pc_seq;     // PC+4 (sequencial)
    wire [31:0] pc_after_branch; // PC após decisão de branch
    wire [31:0] next_pc;         // Próximo PC final
    
    // PC+4 sempre é calculado
    assign pc_plus_4 = pc + 32'd4;
    assign next_pc_seq = pc_plus_4;
    
    // Mux do branch: se branch_taken=1, usa branch_target
    assign pc_after_branch = branch_taken ? branch_target : next_pc_seq;
    
    // Mux do jump: se jump=1, usa jump_target
    assign next_pc = jump ? jump_target : pc_after_branch;
    
    // ===== ATUALIZAÇÃO DO PC (sequencial) =====
    always @(posedge clk) begin
        if(reset) begin
            pc <= 32'b0;  // Reset: PC volta para 0
        end
        else begin
            pc <= next_pc;
        end
    end
    
    // ===== LEITURA DA MEMÓRIA DE INSTRUÇÕES =====
    // Usa os bits [31:2] do PC como endereço (ignora 2 bits inferiores)
    assign instr = instr_mem[pc[31:2]];

endmodule