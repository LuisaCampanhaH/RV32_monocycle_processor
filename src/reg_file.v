// ============================================================
// Módulo: Banco de Registradores (Register File)
// Função: 32 registradores de 32 bits
// Característica: x0 (endereço 0) é sempre zero, não pode ser modificado
// Leitura: Combinacional (assíncrona)
// Escrita: Na borda de subida do clock (síncrona)
// ============================================================

module reg_file(
    input  wire        clk,           // Clock
    input  wire        reg_write,     // Habilita escrita (1 = escrever)
    input  wire [4:0]  rs1_addr,      // Endereço do registrador fonte 1 (leitura)
    input  wire [4:0]  rs2_addr,      // Endereço do registrador fonte 2 (leitura)
    input  wire [4:0]  rd_addr,       // Endereço do registrador destino (escrita)
    input  wire [31:0] write_data,    // Dado a ser escrito
    output wire [31:0] rs1_data,      // Valor lido do registrador rs1
    output wire [31:0] rs2_data       // Valor lido do registrador rs2
);
    
    // Memória dos registradores: 32 palavras de 32 bits
    reg [31:0] registers [0:31];
    
    // Inicializa todos registradores com zero
    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end
    
    // ===== LEITURA COMBINACIONAL =====
    // x0 sempre retorna zero, mesmo se alguém tentou escrever nele
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : registers[rs2_addr];
    
    // ===== ESCRITA SÍNCRONA (na borda de subida do clock) =====
    always @(posedge clk) begin
        // Só escreve se habilitado E se não for x0 (endereço 0)
        if(reg_write && (rd_addr != 5'b0)) begin
            registers[rd_addr] <= write_data;
        end
    end

endmodule