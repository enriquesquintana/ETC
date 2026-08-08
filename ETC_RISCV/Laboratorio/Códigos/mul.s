.globl __start

.text

__start:
    # Leer primer entero
    li a7, 5
    call getInt
    mv s0, a0          # s0 = primer número

    # Leer segundo entero
    li a7, 5
    call getInt
    mv a1, a0          # a1 = segundo número
    mv a0, s0          # a0 = primer número

    # Mult(a0, a1)
    jal ra, Mult

    # Imprimir resultado (a0)
    li a7, 1
    ecall

    # Salir
    li a7, 10
    ecall

Mult:
    li t0, 0            # acumulador
    beqz a1, MultRet
MultFor:
    add t0, t0, a0
    addi a1, a1, -1
    bne a1, zero, MultFor

    mv a0, t0           # resultado → a0
MultRet:
    ret

getInt: # Read a string from stdin
    li a7, 63 # syscall read
    li a0, 0 # stdin
    la a1, buffer # buffer
    li a2, 255 # max bytes
    ecall

    # Convert ASCII digits to integer
    li t0, 0 # t0 = result
    li t1, 0 # index
convertLoop:
    lb t2, 0(a1) # load byte
    li t3, 10
    beq t2, t3, done # newline ASCII = 10
    beq t2, x0, done # null terminator
    li t3, 48 # ASCII '0'
    sub t2, t2, t3 # convert ASCII to number
    blt t2,x0, done # stop if non-digit
    li t3, 9
    bgt t2,t3, done # stop if non-digit
    li t3, 10
    mul t0, t0, t3 # shift decimal left
    add t0, t0, t2 # add digit
    addi a1, a1, 1 # move to next char
    j convertLoop
done:
    mv a0, t0 # return integer in a0
    ret

buffer: .zero 255
