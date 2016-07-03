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
      loadlit r7,-1
      loadlit r6, 1
OV:   add r6,r6,r7
      jf.carry OV 
HLT:  j HLT
      nop
.end
