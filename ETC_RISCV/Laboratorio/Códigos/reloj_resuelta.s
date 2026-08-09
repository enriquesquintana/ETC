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
    li a1,0x00173b3b      # Hora 23:59:59
    jal inicializa_reloj    

    la a0,reloj
    jal imprime_reloj
              
    la a0,reloj
    jal pasa_segundo      # Incrementa el reloj en un segundo
    jal pasa_segundo      # Incrementa el reloj en un segundo
                
    la a0,reloj
    jal imprime_reloj

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
                slli t0,a1,16       # Campo HH en el tercer byte
                slli t1,a2,8        # Campo MM en el segundo byte
                or t0,t0,t1        # $t0 contiene HH:MM:00
                or t0,t0,a3        # $t0 contiene HH:MM:SS
                sw t0,0(a0)        # Escritura del reloj
                ret

##########################################################
inicializa_reloj2: # Con eliminación de múltiples codificaciones
                  li t0,0x001F3F3F # Unos en los campos HH:MM:SS
                  andi t0,a1,50     # Hace ceros el resto de bits
                  sw t0,0(a0)      # Escribe el valor del reloj
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
devuelve_reloj_en_s_sd:
    lbu t0,2(a0)         # t0 = HH
    slli a0,t0,11         # a0 = HH * 2^11
    slli t1,t0,10         # t1 = HH * 2^10
    add a0,a0,t1         # a0 = HH * (2^11 + 2^10)

    slli t1,t0,9          # t1 = HH * 2^9
    add a0,a0,t1         # a0 = HH * (2^11 + 2^10 + 2^9)

    slli t1,t0,4          # t1 = HH * 2^4
    add a0,a0,t1         # a0 = HH * (2^11 + 2^10 + 2^9 + 2^4)

    lbu t0,1(a0)         # t0 = MM
    slli t1,t0,5          # t1 = MM * 2^5
    slli t2,t0,4          # t2 = MM * 2^4
    add t1,t1,t2         # t1 = MM * (2^5 + 2^4)

    slli t2,t0,3          # t2 = MM * 2^3
    add t1,t1,t2         # t1 = MM * (2^5 + 2^4 + 2^3)

    slli t2,t0,2          # t2 = MM * 2^2
    add t1,t1,t2         # t1 = MM * (2^5 + 2^4 + 2^3 + 2^2)

    lbu t0,0(a0)         # t0 = SS

    add a0,a0,t1         # a0 = HH*3600 + MM*60
    add a0,a0,t0         # a0 = HH*3600 + MM*60 + SS

    ret

##########################################################
devuelve_reloj_en_s_srd:
    lbu t0,2(a0)         # t0 = HH
    slli a1,t0,12         # a1 = HH * 2^12
    slli t1,t0,9          # t1 = HH * 2^9
    sub a1,a1,t1         # a1 = HH * (2^12 - 2^9)

    slli t1,t0,5          # t1 = HH * 2^5
    add a1,a1,t1         # a1 = HH * (2^12 - 2^9 + 2^5)

    slli t1,t0,4          # t1 = HH * 2^4
    sub a1,a1,t1         # a1 = HH * (2^12 - 2^9 + 2^5 - 2^4)

    lbu t0,1(a0)         # t0 = MM
    slli t1,t0,6          # t1 = MM * 2^6
    slli t2,t0,2          # t2 = MM * 2^2
    sub t1,t1,t2         # t1 = MM * (2^6 - 2^2)

    add a1,a1,t1         # a1 = HH*3600 + MM*60

    lbu t0,0(a0)         # t0 = SS
    add a1,a1,t0         # a1 = HH*3600 + MM*60 + SS

    mv a0,a1             # valor de retorno en a0
    ret

##########################################################
pasa_segundo:
    lbu t0,0(a0)            # t0 = SS
    addi t0,t0,1            # t0 = SS + 1
    li t1,60
    beq t0,t1,inc_minutos   # Si SS == 60,se incrementa MM
    sb t0,0(a0)             # Escribe SS++
    j fin_pasa_segundo

inc_minutos:
    sb zero,0(a0)           # SS = 0
    lbu t0,1(a0)            # t0 = MM
    addi t0,t0,1            # t0 = MM + 1
    li t1,60
    beq t0,t1,inc_horas     # Si MM == 60,se incrementa HH
    sb t0,1(a0)             # Escribe MM++
    j fin_pasa_segundo

inc_horas:
    sb zero,1(a0)           # MM = 0
    lbu t0,2(a0)            # t0 = HH
    addi t0,t0,1            # t0 = HH + 1
    li t1,24
    beq t0,t1,fin_inc_horas # Si HH == 24, se pone HH a cero
    sb t0,2(a0)             # Escribe HH++
    j fin_pasa_segundo

fin_inc_horas:
    sb zero,2(a0)           # HH = 0

fin_pasa_segundo:
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
