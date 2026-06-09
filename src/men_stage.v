// ============================================================
// Módulo: Estágio MEM (Memory Access)
// Função: Acessar a memória de dados (apenas LW e SW)
// Contém: Memória de dados de 256 palavras
// ============================================================

module mem_stage(
    input  wire        clk,          // Clock
    input  wire        mem_read,     // Habilita leitura
    input  wire        mem_write,    // Habilita escrita
    input  wire [31:0] alu_result,   // Endereço de acesso (da ULA)
    input  wire [31:0] store_data,   // Dado a armazenar (rs2)
    output wire [31:0] mem_read_data // Dado lido da memória
);
    
    // ===== MEMÓRIA DE DADOS =====
    // 256 palavras de 32 bits (1 KB)
    reg [31:0] data_mem [0:255];
    
    // ===== LEITURA COMBINACIONAL =====
    // Se mem_read=1, retorna o dado; senão, retorna 0
    assign mem_read_data = mem_read ? data_mem[alu_result[31:2]] : 32'b0;
    
    // ===== ESCRITA SÍNCRONA =====
    always @(posedge clk) begin
        if(mem_write) begin
            data_mem[alu_result[31:2]] <= store_data;
        end
    end

endmodule