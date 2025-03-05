.section .text
.global _start

_start:
    li x1, 5
    li x2, 10
    add x3, x1, x2
    ebreak
    j _start

