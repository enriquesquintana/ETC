##########################################################
# Segmento de datos
##########################################################

.data

reloj:           .word 0                # HH:MM:SS

cad_asteriscos:  .asciz "\n  ************************************"
cad_horas:       .asciz "\n   Horas: "
cad_minutos:     .asciz " Minutos: "
cad_segundos:    .asciz " Segundos: "
cad_reloj_en_s:  .asciz "\n   Reloj en segundos: "


##########################################################
# Segmento de código
##########################################################

.text
.globl __start

__start:
    la a0,reloj
    li a1,0x0002030C
    jal inicializa_reloj

    la a0,reloj
    jal ra,imprime_reloj

salir:
    li a7,10              # Código de exit
    ecall

##########################################################
# Inicializa_reloj
##########################################################
inicializa_reloj: sw a1,0(a0)
                  ret

##########################################################
# Subrutina que imprime el valor del reloj
#
# Entrada:
#   a0 = dirección de la variable reloj
##########################################################

imprime_reloj:
    mv t0,a0

    la a0,cad_asteriscos
    li a7,4               # print_string
    ecall

    la a0,cad_horas
    li a7,4               # print_string
    ecall

    lbu a0,2(t0)          # HH
    li a7,1               # print_int
    ecall

    la a0,cad_minutos
    li a7,4               # print_string
    ecall

    lbu a0,1(t0)          # MM
    li a7,1               # print_int
    ecall

    la a0,cad_segundos
    li a7,4               # print_string
    ecall

    lbu a0,0(t0)          # SS
    li a7,1               # print_int
    ecall

    la a0,cad_asteriscos
    li a7,4               # print_string
    ecall

    ret


##########################################################
# Subrutina que imprime los segundos calculados
#
# Entrada:
#   a0 = segundos a imprimir
##########################################################

imprime_s:
    mv t0,a0

    la a0,cad_asteriscos
    li a7,4               # print_string
    ecall

    la a0,cad_reloj_en_s
    li a7,4               # print_string
    ecall

    mv a0,t0              # Valor entero a imprimir
    li a7,1               # print_int
    ecall

    la a0,cad_asteriscos
    li a7,4               # print_string
    ecall

    ret


##########################################################
# Subrutina que incrementa el reloj en una hora
#
# Entrada:
#   a0 = dirección del reloj
# Salida:
#   reloj incrementado en memoria
#
# 23:MM:SS -> 00:MM:SS
##########################################################

pasa_hora:
    lbu t0,2(a0)         # t0 = HH
    addi t0,t0,1         # t0 = HH + 1

    li t1,24
    beq t0,t1,H24        # Si HH == 24

    sb t0,2(a0)          # Escribe HH + 1
    j fin_pasa_hora

H24:
    sb zero,2(a0)        # Escribe HH = 0

fin_pasa_hora:
    ret
