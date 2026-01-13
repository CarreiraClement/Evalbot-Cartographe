SYSCTL_RCGC2    EQU     0x400FE108
PORTD_BASE      EQU     0x40007000

GPIO_O_DIR      EQU     0x400
GPIO_O_DEN      EQU     0x51C
GPIO_O_PUR      EQU     0x510

PIN_SW1         EQU     0x40
PIN_SW2         EQU     0x80

        AREA    |.text|, CODE, READONLY

        EXPORT  SWITCH_INIT
        EXPORT  READ_SW1
        EXPORT  READ_SW2

SWITCH_INIT
        ldr r6, =SYSCTL_RCGC2
        ldr r0, [r6]
        orr r0, r0, #0x08
        str r0, [r6]

        nop
        nop
        nop

        ldr r6, =PORTD_BASE + GPIO_O_DIR
        ldr r0, [r6]
        bic r0, r0, #(PIN_SW1 + PIN_SW2)
        str r0, [r6]

        ldr r6, =PORTD_BASE + GPIO_O_PUR
        ldr r0, [r6]
        orr r0, r0, #(PIN_SW1 + PIN_SW2)
        str r0, [r6]

        ldr r6, =PORTD_BASE + GPIO_O_DEN
        ldr r0, [r6]
        orr r0, r0, #(PIN_SW1 + PIN_SW2)
        str r0, [r6]

        BX LR

READ_SW1
        ldr r6, =PORTD_BASE + (PIN_SW1 << 2)
        ldr r0, [r6]
        cmp r0, #0
        BEQ SW1_Pressed
        mov r0, #0
        BX LR
SW1_Pressed
        mov r0, #1
        BX LR

READ_SW2
        ldr r6, =PORTD_BASE + (PIN_SW2 << 2)
        ldr r0, [r6]
        cmp r0, #0
        BEQ SW2_Pressed
        mov r0, #0
        BX LR
SW2_Pressed
        mov r0, #1
        BX LR

        END