.section .data
input1: .byte 0x01, 0xF7, 0x00, 0x00, 0x01, 0xD2, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00    @ two positive nfp
input2: .byte 0x81, 0xF7, 0x00, 0x00, 0x01, 0xD2, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00    @ one negative and one positive nfp
input3: .byte 0x81, 0xD2, 0xA0, 0x00, 0x81, 0xF7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00    @ two negative nfp
input4: .byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
input5: .byte 0x12, 0x34, 0x56, 0x78, 0x87, 0x65, 0x43, 0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
input6: .byte 0x00, 0x02, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
input7: .byte 0x80, 0x16, 0x00, 0x00, 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
input8: .byte 0x40, 0x01, 0x00, 0x00, 0x40, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
input9: .byte 0x00, 0x26, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
input10: .byte 0x00, 0x26, 0x00, 0x00, 0x80, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
input11: .byte 0x80, 0x26, 0x00, 0x00, 0x80, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
input12: .byte 0x7F, 0xF6, 0x00, 0x00, 0x7F, 0xDB, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 

.section .text
.global _start

@ first nfp       = r0
@ second nfp      = r2
@ first mantisa   = r8
@ second mantisa  = r9
@ first exponent  = r6
@ second exponent = r7
@ first sign bit  = r4
@ second sign bit = r5
@ final sign bit  = r4
@ final exponent  = r7
@ final mantisa   = r3
@ final result    = r0
@ offset for addr = r6 

special:
    stmfd sp!, {r4-r5, lr}
    mov r4, #1           
    LSL r4, #18                @ for checking the 19th bit, r4 = 1000000000000000000
    loop8:
        AND r5, r4, r3         @ checking the 19th bit
        LSR r5, #18            @ shifting it by 18 bit to right
        cmp r5, #1             @ comparing it with 1
        subne r7, r7, #1           @ if not equal then decrease the exponent by 1
        LSLne r3, #1           @ shift the mantisa to the left by one
        bne loop8              @ run the loop again
    ldmfd sp!, {r4-r5, pc}
        
load1:
    stmfd sp!, {r2, r3, r4, r7, r8, r9, lr}

    mov r9, #3
    mov r8, #0
    mov r0, #0
    loop1:
        ldrb r7, [r1, r8]
        add r0, r0, r7
        mov r0, r0, LSL #8
        add r8, r8, #1
        subs r9, r9, #1
        bne loop1
        ldrb r7, [r1, r8]
        add r0, r0, r7

    ldmfd sp!, {r2, r3, r4, r7, r8, r9, pc}

load2:
    stmfd sp!, {r3, r4, r5, r6, r7, r8, r9, lr}

    mov r9, #3
    mov r8, #4
    mov r2, #0
    loop2:
        ldrb r7, [r1, r8]
        add r2, r2, r7
        mov r2, r2, LSL #8
        add r8, r8, #1
        subs r9, r9, #1
        bne loop2
        ldrb r7, [r1, r8]
        add r2, r2, r7

    ldmfd sp!, {r3, r4, r5, r6, r7, r8, r9, pc}

mantisa:
    stmfd sp!, {r3, lr}

    mov r3, #1
    mov r8, #18
    loop3:
        mov r3, r3, LSL #1
        add r3, r3, #1
        subs r8, r8, #1
        bne loop3
    AND r8, r0, r3         @ mantisa of first NFP in r8
    AND r9, r2, r3         @ manitsa of second NFP in r9
    mov r0, r0, LSR #19
    mov r2, r2, LSR #19

    ldmfd sp!, {r3, pc}

exponent:
    stmfd sp!, {r3, lr}

    mov r3, #1
    mov r6, #11
    loop4:
        mov r3, r3, LSL #1
        add r3, r3, #1
        subs r6, r6, #1
        bne loop4  
    AND r6, r0, r3         @ exponent of first NFP in r6
    AND r7, r2, r3         @ exponent of second NFP in r7
    mov r0, r0, LSR #12
    mov r2, r2, LSR #12

    ldmfd sp!, {r3, pc}

signbit:
    stmfd sp!, {r3, lr}

    mov r3, #1
    AND r4, r0, r3         @ sign bit of first NFP in r4
    AND r5, r2, r3         @ sign bit of second NFP in r5

    ldmfd sp!, {r3, pc}

renormalize:
    stmfd sp!, {r6, lr}

    mov r6, #1572864
    AND r0, r3, r6        @ finding the 20th and 21st bit of mantisa
    mov r0, r0, LSR #19   

    cmp r0, #3            @ comparing it with 11
    moveq r3, r3, LSR #1  @ if equal then right shift mantisa by 1
    addeq r7, r7, #1      @ if equal then increase the exponent by 1

    cmp r0, #2            @ comparing it with 10 
    moveq r3, r3, LSR #1  @ if equal then right shift mantisa by 1
    addeq r7, r7, #1      @ if equal then increase the exponent by 1

    cmp r0, #0            @ comparing it with 00
    bleq special          @ calling special function
    subeq r7, #1          @ now we have our mantisa as 0.1_ _ _ _ _ _, so decrease the exponent by 1
    LSLeq r3, #1          @ left shift the mantisa

    sub r3, r3, #524288   @ remove the significant part

    ldmfd sp!, {r6, pc}

finalresult:
    stmfd sp!, {r5-r6, lr}

    mov r0, r4, LSL #31   @ r0 = resulting nfp
    mov r5, #1
    mov r6, #11
    loop10:
        mov r5, r5, LSL #1
        add r5, r5, #1
        subs r6, r6, #1
        bne loop10
    AND r5, r5, r7        @ extracting the exponent  {only when exponent is negative, else we can directly shift}
    mov r5, r5, LSL #19   @ shifting the exponent by 19 (mantisa) bits
    ORR r0, r0, r5       @ putting the exponent to final nfp (r0)
    ORR r0, r0, r3        @ putting the mantisa to final nfp (r0)

    ldmfd sp!, {r5-r6, pc}

storing:
    stmfd sp!, {r3,r4, lr}

    mov r4, #4            @ r4 = no. of loops
    mov r3, #0xFF         @ r3 = 1111 1111
    loop7:
        AND r2, r0, r3    @ extracting the first 8 bits
        strb r2, [r1, r6] @ storing the extracted bit at r1 address with r6 offset
        sub r6, r6, #1    @ decreasing the offset
        LSR r0, #8        @ shifting the final nfp by 8 bits to the right
        subs r4, r4, #1   @ decreasing the no. of loops by 1
        bne loop7         

    ldmfd sp!, {r3,r4, pc}

@ ******************************************* addition of nfp *************************************************    

nfpadd:
    stmfd sp!, {r0, r2-r9, lr}

    @ first NFP in r0
    bl load1

    @ second NFP in r2
    bl load2

    @ getting the mantisa
    bl mantisa

    @ getting the exponent 
    bl exponent
    
    @ getting the sign bit
    bl signbit
    
    @ extending the sign bit of exponent
    mov r0, #1
    mov r2, #19
    loop9:
        LSL r0, #1
        add r0, r0, #1
        subs r2, r2, #1
        bne loop9
    LSL r0, #12

    mov r3, #0x800
    AND r3, r3, r6
    LSR r3, #11
    
    cmp r3, #1
    orreq r6, r6, r0 

    mov r3, #0x800
    AND r3, r3, r7
    LSR r3, #11

    cmp r3, #1
    orreq r7, r7, r0

    @ making the exponent same         r7 = exponent

    mov r3, #1
    mov r3, r3, LSL #19
    ORR r9, r9, r3    @ making the mantisa as 1._ _ _ _ 
    ORR r8, r8, r3    @ making the mantisa as 1._ _ _ _ 

    cmp r6, r7             @ comparing the exponents 
    subgt r3, r6, r7       @ r3 = r6 - r7   if: r6 > r7
    sublt r3, r7, r6       @ r3 = r7 - r6   if: r6 < r7
    addgt r7, r7, r3       @ r7 = r7 + r3   if: r6 > r7
    addlt r6, r6, r3       @ r6 = r6 + r3   if: r6 < r7
    movgt r9, r9, LSR r3   @ shift the mantisa of 2nd nfp by r3 bits
    movlt r8, r8, LSR r3   @ shift the mantisa of 1st nfp by r3 bits

    @ adding the mantisa      r4 = sign bit

    mov r6, #0

    cmp r4, #1
    subeq r8, r6, r8       @ if the sign bit of the 1st nfp is 1 then make the mantisa negative

    cmp r5, #1
    subeq r9, r6, r9       @ if the sign bit of the 2nd nfp is 1 then make the mantisa negative

    add r3, r8, r9        @ r3 = mantisa    ; r3 = r8 + r9

    cmp r3, #0
    movgt r4, #0          @ if r3 is greater than 0 i.e. positive then sign bit i.e. r4=0
    movlt r4, #1          @ if r3 is less than 0 i.e. negative then sign bit i.e. r4=0

    cmp r3, #0
    sublt r3, r6, r3      @ if final addition result is negative then make it positive

    cmp r3, #0
    moveq r4, #0          @ if r3 is equal to 0 then sign bit i.e. r4=0

    @ renormalizing
    bl renormalize

    @ creating the final nfp
    bl finalresult

    @ storing the final npf
    mov r6, #11
    bl storing

    ldmfd sp!, {r0, r2-r9, pc}

@  ******************************************* multiplication ***************************************************

nfpmul:
    stmfd sp!, {r0, r2-r9, lr}
    
    @ first NFP in r0
    bl load1

    @ second NFP in r2
    bl load2

    @ getting the mantisa
    bl mantisa

    @ getting the exponent 
    bl exponent

    mov r3, #1
    mov r3, r3, LSL #19
    ORR r9, r9, r3    @ making the mantisa as 1._ _ _ _ 
    ORR r8, r8, r3    @ making the mantisa as 1._ _ _ _

    @ getting the sign bit
    bl signbit  

    @ extending the sign bit of exponent
    mov r0, #1
    mov r2, #19
    loop5:
        LSL r0, #1
        add r0, r0, #1
        subs r2, r2, #1
        bne loop5
    LSL r0, #12

    mov r3, #0x800
    AND r3, r3, r6
    LSR r3, #11
    
    cmp r3, #1
    orreq r6, r6, r0 

    mov r3, #0x800
    AND r3, r3, r7
    LSR r3, #11

    cmp r3, #1
    orreq r7, r7, r0

    @ adding the exponent
    add r7, r7, r6

    @ getting the final sign bit
    EOR r4, r4, r5

    @ multiplying the mantisa
    UMULL r3, r2, r8, r9                        @ r2, r3 stores the final mantisa

    @ renormalizing the mantisa
    mov r0, #13
    mov r6, #1 
    LSL r6, #31

    loop6:                                      @ bringing the mantisa in r2
        AND r5, r6, r3
        LSR r5, #31
        LSL r2, #1
        add r2, r2, r5
        subs r0, r0, #1
        LSL r3, #1
        bne loop6

    mov r3, r2                                  @ moving the mantisa in r3

    bl renormalize

    @ getting the final result
    bl finalresult

    @ storing the final nfp
    mov r6, #15
    bl storing

    ldmfd sp!, {r0, r2-r9, pc}

@ ******************************************* main function ****************************************************

_start:
ldr r1, =input11
bl nfpadd
bl nfpmul