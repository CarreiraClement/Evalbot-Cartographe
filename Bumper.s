SYSCTL_RCGC2    EQU     0x400FE108
PORTE_BASE      EQU     0x40024000 ; Adresse de base du Port E

GPIO_O_DIR      EQU     0x400
GPIO_O_DEN      EQU     0x51C
GPIO_O_PUR      EQU     0x510

; Définition des masques (et non des numéros de bit)
PIN_BUMP_L      EQU     0x02       ; Bit 1 (0000 0010)
PIN_BUMP_R      EQU     0x01       ; Bit 0 (0000 0001)

        AREA    |.text|, CODE, READONLY

        EXPORT  BUMPER_INIT
        EXPORT  READ_BUMP_L
        EXPORT  READ_BUMP_R

BUMPER_INIT
        ldr r6, =SYSCTL_RCGC2
        ldr r0, [r6]
        ; CORRECTION ICI : Pour le Port E, il faut le bit 4 (0x10), pas le bit 2 (0x04)
        ; Bit 0=A, 1=B, 2=C, 3=D, 4=E, 5=F
        orr r0, r0, #0x10
        str r0, [r6]

        ; Attente pour la stabilisation de l'horloge (3 cycles min)
        nop
        nop
        nop

        ; Configuration de la Direction (Input = 0)
        ldr r6, =PORTE_BASE + GPIO_O_DIR
        ldr r0, [r6]
        bic r0, r0, #(PIN_BUMP_L + PIN_BUMP_R) ; Force les bits à 0 pour Input
        str r0, [r6]

        ; Configuration Pull-Up (Interrupteur vers la masse)
        ldr r6, =PORTE_BASE + GPIO_O_PUR
        ldr r0, [r6]
        orr r0, r0, #(PIN_BUMP_L + PIN_BUMP_R) ; Active les résistances de tirage
        str r0, [r6]

        ; Activation Numérique
        ldr r6, =PORTE_BASE + GPIO_O_DEN
        ldr r0, [r6]
        orr r0, r0, #(PIN_BUMP_L + PIN_BUMP_R) ; Active la fonction numérique
        str r0, [r6]

        BX LR

READ_BUMP_L
        ; Lecture masquée (Bit-Banding adresse)
        ; L'offset est (Masque << 2). Pour PIN 1 (0x02), offset = 0x08.
        ldr r6, =PORTE_BASE + (PIN_BUMP_L << 2)
        ldr r0, [r6]
        cmp r0, #0
        BEQ BL_Hit      ; Si 0, le bouton est appuyé (car Pull-Up)
        mov r0, #0      ; Sinon, renvoie 0
        BX LR
BL_Hit
        mov r0, #1      ; Renvoie 1 si appuyé
        BX LR

READ_BUMP_R
        ; Pour PIN 0 (0x01), offset = 0x04.
        ldr r6, =PORTE_BASE + (PIN_BUMP_R << 2)
        ldr r0, [r6]
        cmp r0, #0
        BEQ BR_Hit
        mov r0, #0
        BX LR
BR_Hit
        mov r0, #1
        BX LR

        END