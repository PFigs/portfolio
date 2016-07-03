.module teste1
.pseg
        ;; testa salto condicional neg, carry e overflow
        ;; r7=0x0001
        ;; r0 = 0xaa55
        ;; r1 = 0xffff
        ;; r2 = 0xaa55 (0x0000 Errado)
        ;; r3 = 0xaa55 (senao flag de carry no lsl)
        ;; r4 = r3(0xaa55) (0x54aa Errado) 
main:
      loadlit r6,8
OV:   deca r6,r6
      jt.zero HLT 
HLT:  j HLT
      nop
.end
