         .glob __start

         .text      
__start: li s0,32
         li s1,127
loop:
         li a7,1
         mv a0,s0
         ecall
         li a7,11
         li a0,9
         ecall
         li a7,11
         mv a0,s0
         ecall
         li a7,11
         li a0,10
         ecall

         addi s0,s0,1
         blt s0,s1,loop

         li a7,10
         ecall

