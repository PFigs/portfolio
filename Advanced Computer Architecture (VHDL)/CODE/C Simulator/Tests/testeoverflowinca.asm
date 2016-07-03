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
      loadlit r6,1023
      loadlit r7,0
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
      add r7,r7,r6
OV:   inca r7,r7
      jf.overflow OV 
HLT:  j HLT
      nop
.end
