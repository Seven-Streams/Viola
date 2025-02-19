# Viola

## What's Viola
Viola(CPU implemented by **V**er**i**l**o**g for RISCV-i with Tomasu**l**o **a**lgorithm) is a CPU written in Verilog, supporting the basic instructions in RISCV-i.

It supports these instrucions:
`LUI, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU, LB, LH, LW, LBU, LHU, SB, SH, SW, ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI, ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND, c.addi，c.jal，c.li，c.addi16sp，c.lui，c.srli，c.srai，c.andi，c.sub，c.xor，c.or，c.and，c.j，c.beqz，c.bnez，c.addi4spn，c.lw，c.sw，c.slli，c.jr，c.mv，c.jalr，c.add，c.lwsp，c.swsp`

Tomasulo algorithm is implemented in Viola. The frequency of Viola is 100 MHz.
