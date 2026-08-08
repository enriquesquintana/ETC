          .globl __start
          .data
vector:   .word 1,2,3,4,5,6,7,8,9 # ... Suponemos un vector infinito


          .text
__start:
          li s0,0
          la t0,vector
loop:
          lw s1,0(t0)
          addi t0,t0,4
          add  s0,s0,s1
          li a7,1	
          mv a0,s1
          ecall
          li a7,11
          li a0,10
          ecall
          j loop

          li a7,10 
          ecall

