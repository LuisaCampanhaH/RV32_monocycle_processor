// ============================================================
// Módulo: TOPO do Processador RV32I Monociclo
// Função: Integrar todos os 5 estágios e a unidade de controle
// Este é o módulo principal que instancia todos os outros
// ============================================================

module top_processor(
    input  wire clk,     // Clock do sistema
    input  wire reset    // Reset do processador
);
    
    // ==========================================
    // DECLARAÇÃO DE TODOS OS FIOS DE INTERCONEXÃO
    // ==========================================
    
    // IF -> ID
    wire [31:0] pc, pc_plus_4, instr;
    
    // ID -> EX
    wire [31:0] rs1_data, rs2_data, imm;
    wire        alu_src, mem_read, mem_write;
    wire        branch, jump, mem_to_reg;
    wire [1:0]  alu_op;
    
    // EX -> MEM
    wire [31:0] alu_result;
    wire        zero;
    wire [31:0] branch_target;
    
    // MEM -> WB
    wire [31:0] mem_read_data;
    
    // WB -> ID
    wire [31:0] write_data;
    
    // Sinais de controle
    wire        reg_write;
    wire [4:0]  rd_addr;
    
    // Sinais especiais
    wire        branch_taken;
    wire [31:0] jump_target;
    wire        is_lui;
    wire [31:0] lui_imm;
    
    // ==========================================
    // EXTRAIR CAMPOS DA INSTRUÇÃO
    // ==========================================
    assign rd_addr   = instr[11:7];   // Registrador destino
    wire [2:0] funct3 = instr[14:12]; // Campo funct3
    wire funct7_5     = instr[30];    // Bit 30 (funct7[5])
    wire [6:0] opcode = instr[6:0];   // Opcode
    
    // ==========================================
    // DETECÇÃO DE LUI
    // ==========================================
    assign is_lui   = (opcode == 7'b0110111);
    assign lui_imm  = {instr[31:12], 12'b0}; // Imediato shiftado
    
    // ==========================================
    // INSTANCIAR ESTÁGIO IF (Instruction Fetch)
    // ==========================================
    if_stage if_stage_inst(
        .clk(clk),
        .reset(reset),
        .branch_taken(branch_taken),
        .jump(jump),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .pc(pc),
        .pc_plus_4(pc_plus_4),
        .instr(instr)
    );
    
    // ==========================================
    // INSTANCIAR ESTÁGIO ID (Instruction Decode)
    // ==========================================
    id_stage id_stage_inst(
        .clk(clk),
        .instr(instr),
        .write_data(write_data),
        .rd_addr(rd_addr),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op)
    );
    
    // Obter o sinal reg_write da unidade de controle
    // (já que o id_stage não exporta reg_write diretamente)
    wire reg_write_from_ctrl;
    control_unit ctrl_for_regwrite(
        .opcode(opcode),
        .reg_write(reg_write_from_ctrl),
        .alu_src(),
        .mem_read(),
        .mem_write(),
        .branch(),
        .jump(),
        .mem_to_reg(),
        .alu_op()
    );
    assign reg_write = reg_write_from_ctrl;
    
    // ==========================================
    // INSTANCIAR ESTÁGIO EX (Execute)
    // ==========================================
    ex_stage ex_stage_inst(
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm),
        .pc(pc),
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_src(alu_src),
        .alu_result(alu_result),
        .zero(zero),
        .branch_target(branch_target)
    );
    
    // ==========================================
    // LÓGICA DE BRANCH
    // ==========================================
    // branch_taken = branch AND (condição atendida)
    // BEQ:  zero=1 quando rs1==rs2  → branch_taken = branch & zero
    // BNE:  zero=0 quando rs1!=rs2  → branch_taken = branch & ~zero
    // BLT:  verificado via funct3 na prática
    // Simplificação: usamos zero e funct3 para decidir
    reg branch_condition;
    always @(*) begin
        case(funct3)
            3'b000: branch_condition = zero;                   // BEQ
            3'b001: branch_condition = ~zero;                  // BNE
            3'b100: branch_condition = $signed(rs1_data) < $signed(rs2_data); // BLT
            3'b101: branch_condition = $signed(rs1_data) >= $signed(rs2_data); // BGE
            3'b110: branch_condition = rs1_data < rs2_data;    // BLTU
            3'b111: branch_condition = rs1_data >= rs2_data;   // BGEU
            default: branch_condition = 1'b0;
        endcase
    end
    assign branch_taken = branch & branch_condition;
    
    // ==========================================
    // ENDEREÇO DE JUMP (JAL e JALR)
    // ==========================================
    // JAL:  jump_target = pc + imm
    // JALR: jump_target = (rs1 + imm) & ~1  (limpa bit 0)
    wire [31:0] jal_target  = pc + imm;
    wire [31:0] jalr_target = (rs1_data + imm) & ~32'd1;
    
    // Seleciona entre JAL e JALR baseado no opcode
    assign jump_target = (opcode == 7'b1100111) ? jalr_target : jal_target;
    
    // ==========================================
    // INSTANCIAR ESTÁGIO MEM (Memory Access)
    // ==========================================
    mem_stage mem_stage_inst(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_result(alu_result),
        .store_data(rs2_data),
        .mem_read_data(mem_read_data)
    );
    
    // ==========================================
    // INSTANCIAR ESTÁGIO WB (Write Back)
    // ==========================================
    wb_stage wb_stage_inst(
        .alu_result(alu_result),
        .mem_read_data(mem_read_data),
        .pc_plus_4(pc_plus_4),
        .mem_to_reg(mem_to_reg),
        .jump(jump),
        .lui_imm(lui_imm),
        .is_lui(is_lui),
        .write_data(write_data)
    );

endmodule