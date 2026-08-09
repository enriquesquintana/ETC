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
inicializa_reloj: sw a1,0(a0)
                  ret

##########################################################
inicializa_reloj_ss:  
                sb a1,0(a0)
                ret

inicializa_reloj_mm:
                sb a1,1(a0)
                ret

inicializa_reloj_hh:  
                sb a1,2(a0)
                ret

##########################################################
inicializa_reloj_alt:       
                sll t0,a1,16       # Campo HH en el tercer byte
                sll t1,a2,8        # Campo MM en el segundo byte
                or t0,t0,t1        # $t0 contiene HH:MM:00
                or t0,t0,a3        # $t0 contiene HH:MM:SS
                sw t0,0(a0)        # Escritura del reloj
                ret

##########################################################
inicializa_reloj2: # Con eliminación de múltiples codificaciones
                  li t0,0x001F3F3F # Unos en los campos HH:MM:SS
                  and t0,a1,50     # Hace ceros el resto de bits
                  sw 50,0(a0)      # Escribe el valor del reloj
                  ret

##########################################################
devuelve_reloj_en_s:
    mv t2,a0             # t2 = dirección de reloj
    lbu t0,2(t2)         # t0 = HH
    li  t1,3600
    mul t0,t0,t1         # t0 = HH * 3600
    mv  a0,t0            # a0 = HH * 3600
    lbu t0,1(t2)         # t0 = MM
    li  t1,60
    mul t0,t0,t1         # t0 = MM * 60
    add a0,a0,t0         # a0 = HH*3600 + MM*60
    lbu t0,0(t2)         # t0 = SS
    add a0,a0,t0         # a0 = HH*3600 + MM*60 + SS
    ret

##########################################################
inicializa_reloj_en_s:
    li   t0,60
    divu t1,a1,t0        # t1 = segundos / 60 = minutos totales
    remu t2,a1,t0        # t2 = segundos % 60 = SS
    sb   t2,0(a0)         # reloj.SS = t2
    divu t2,t1,t0        # t2 = minutos / 60 = HH
    remu t1,t1,t0        # t1 = minutos % 60 = MM
    sb   t1,1(a0)         # reloj.MM = t1
    sb   t2,2(a0)         # reloj.HH = t2
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
    lbu t0,2(a0)          # t0 = HH
    addi t0,t0,1         # t0 = HH + 1

    li t1,24
    beq t0,t1,H24        # Si HH == 24

    sb t0,2(a0)           # Escribe HH + 1
    j fin_pasa_hora

H24:
    sb zero,2(a0)         # Escribe HH = 0

fin_pasa_hora:
    ret
