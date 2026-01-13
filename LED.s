SYSCTL_RCGC2    EQU     0x400FE108
PORTF_BASE      EQU     0x40025000

GPIO_O_DIR      EQU     0x400
GPIO_O_DEN      EQU     0x51C
GPIO_O_DR2R     EQU     0x500

PIN_LED1        EQU     0x10
PIN_LED2        EQU     0x20

        AREA    |.text|, CODE, READONLY
        
        EXPORT  LED_INIT
        EXPORT  LED1_ON
        EXPORT  LED1_OFF
        EXPORT  LED2_ON
        EXPORT  LED2_OFF

LED_INIT
        ldr r6, =SYSCTL_RCGC2
        ldr r0, [r6]
        orr r0, r0, #0x20
        str r0, [r6]

        nop
        nop
        nop

        ldr r6, =PORTF_BASE + GPIO_O_DIR
        ldr r0, [r6]
        orr r0, r0, #(PIN_LED1 + PIN_LED2)
        str r0, [r6]

        ldr r6, =PORTF_BASE + GPIO_O_DR2R
        ldr r0, [r6]
        orr r0, r0, #(PIN_LED1 + PIN_LED2)
        str r0, [r6]

        ldr r6, =PORTF_BASE + GPIO_O_DEN
        ldr r0, [r6]
        orr r0, r0, #(PIN_LED1 + PIN_LED2)
        str r0, [r6]

        BX LR

LED1_ON
        ldr r6, =PORTF_BASE + (PIN_LED1 << 2)
        mov r0, #PIN_LED1
        str r0, [r6]
        BX LR

LED1_OFF
        ldr r6, =PORTF_BASE + (PIN_LED1 << 2)
        mov r0, #0
        str r0, [r6]
        BX LR

LED2_ON
        ldr r6, =PORTF_BASE + (PIN_LED2 << 2)
        mov r0, #PIN_LED2
        str r0, [r6]
        BX LR

LED2_OFF
        ldr r6, =PORTF_BASE + (PIN_LED2 << 2)
        mov r0, #0
        str r0, [r6]
        BX LR

        END