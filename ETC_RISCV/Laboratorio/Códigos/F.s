main:
      li a0,5
      jal ra,F
      mv s0,a0

      li a0,20
      jal ra,F
      mv s1,a0

   F: addi t0,a0,1
      mv a0,t0
      ret
