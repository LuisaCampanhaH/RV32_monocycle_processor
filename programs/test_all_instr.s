# ============================================================
# Programa de Teste: TODAS as 30 instruções RV32I
# Para ser compilado e convertido para .hex
# ============================================================

.text
.globl _start

_start:
    # ===== U-type (1 instrução) =====
    lui x1, 0x12345          # x1 = 0x12345000
    
    # ===== I-type aritméticos (8 instruções) =====
    addi x2, x0, 100         # x2 = 100
    slti x3, x2, 200         # x3 = 1 (100 < 200 verdadeiro)
    sltiu x4, x2, 50         # x4 = 0 (100 < 50 falso, unsigned)
    xori x5, x2, 0xFF        # x5 = 100 XOR 255 = 155
    ori x6, x2, 0xF0         # x6 = 100 OR 240 = 244
    andi x7, x2, 0x0F        # x7 = 100 AND 15 = 4
    slli x8, x2, 2           # x8 = 100 << 2 = 400
    srli x9, x2, 1           # x9 = 100 >> 1 = 50
    srai x10, x2, 1          # x10 = 100 >>> 1 = 50
    
    # ===== R-type (10 instruções) =====
    add x11, x2, x8          # x11 = 100 + 400 = 500
    sub x12, x8, x2          # x12 = 400 - 100 = 300
    sll x13, x2, x2          # x13 = 100 << 100 = 0 (shift > 31)
    slt x14, x2, x8          # x14 = 1 (100 < 400)
    sltu x15, x8, x2         # x15 = 0 (400 < 100 falso)
    xor x16, x2, x6          # x16 = 100 XOR 244 = 144
    srl x17, x8, x2          # x17 = 400 >> 100 = 0
    sra x18, x8, x2          # x18 = 400 >>> 100 = 0
    or x19, x2, x6           # x19 = 100 OR 244 = 244
    and x20, x2, x7          # x20 = 100 AND 4 = 4
    
    # ===== Load/Store (2 instruções) =====
    addi x21, x0, 256        # x21 = 256 (endereço base)
    sw x2, 0(x21)            # Mem[256] = 100
    lw x23, 0(x21)           # x23 = Mem[256] = 100
    
    # ===== Branches condicionais (6 instruções) =====
    addi x24, x0, 5          # x24 = 5
    addi x25, x0, 5          # x25 = 5
    beq x24, x25, equal      # Salta (5 == 5)
    addi x26, x0, 1          # NÃO deve executar
equal:
    addi x26, x0, 0          # x26 = 0 (sinaliza que BEQ funcionou)
    
    bne x24, x26, diff       # Salta (5 != 0)
    addi x27, x0, 1          # NÃO deve executar
diff:
    addi x27, x0, 2          # x27 = 2 (sinaliza que BNE funcionou)
    
    blt x24, x25, lt         # NÃO salta (5 não é < 5)
    addi x28, x0, 1          # Executa: x28 = 1
    jal x0, skip             # Pula o label lt
lt:
    addi x28, x0, 0          # NÃO executa
skip:
    
    bge x24, x25, ge         # Salta (5 >= 5)
    addi x30, x0, 1          # NÃO deve executar
ge:
    addi x30, x0, 0          # x30 = 0 (sinaliza que BGE funcionou)
    
    # ===== Jumps incondicionais (2 instruções) =====
    jal x29, target          # x29 = PC+4, salta para target
    addi x31, x0, 1          # NÃO deve executar
target:
    jalr x31, x29, 0         # x31 = PC+4, retorna (mas já está aqui)
    
    # ===== Fim do programa =====
    addi x31, x0, 0xFF       # x31 = 255 (marca final do teste)
    
fim:
    nop                      # Loop infinito suave
    jal x0, fim              # Mantém PC neste ponto

.end