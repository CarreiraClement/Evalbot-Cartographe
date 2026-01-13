; RK - Evalbot (Cortex M3 Texas Instrument)
; Fichier : Exploration.s
; Objectif : Navigation, Rejeu synchronis� et Signaux LED pendant les virages

        AREA    |DATA_RAM|, DATA, READWRITE
PATH_START      SPACE   800 ; Alloue 800 octets de mémoire dans la RAM (max 200 mouvements)            
PATH_END        DCD     0

        AREA    |.text|, CODE, READONLY

        IMPORT  LED_INIT
        IMPORT  LED1_ON
        IMPORT  LED1_OFF
        IMPORT  LED2_ON
        IMPORT  LED2_OFF
        IMPORT  SWITCH_INIT
        IMPORT  READ_SW1
        IMPORT  READ_SW2
        IMPORT  BUMPER_INIT
        IMPORT  READ_BUMP_L
        IMPORT  READ_BUMP_R
        IMPORT  MOTEUR_INIT
        IMPORT  MOTEUR_DROIT_ON
        IMPORT  MOTEUR_DROIT_OFF
        IMPORT  MOTEUR_DROIT_AVANT
        IMPORT  MOTEUR_DROIT_ARRIERE
        IMPORT  MOTEUR_GAUCHE_ON
        IMPORT  MOTEUR_GAUCHE_OFF
        IMPORT  MOTEUR_GAUCHE_AVANT
        IMPORT  MOTEUR_GAUCHE_ARRIERE

        ENTRY
        EXPORT  __main

__main
    BL      LED_INIT
    BL      SWITCH_INIT
    BL      BUMPER_INIT
    BL      MOTEUR_INIT
    
    LDR     R11, =PATH_START    ; Pointeur d'�criture
    MOV     R4, #0              ; Compteur de distance

    BL      MOTEUR_DROIT_ON
    BL      MOTEUR_GAUCHE_ON

exploration_loop
    ; Par d�faut, �teindre les LED en ligne droite
    BL      LED1_OFF
    BL      LED2_OFF
    BL      MOTEUR_DROIT_AVANT
    BL      MOTEUR_GAUCHE_AVANT

CHECK_INPUTS
    ADD     R4, R4, #1          ; Incr�ment de distance

    ; 1. ARR�T ET SAUVEGARDE FINALE
    BL      READ_SW1
    CMP     R0, #1
    BEQ     FINAL_SAVE          ; Sauvegarde avant l'arr�t

    ; 2. REJEU DIRECT
    BL      READ_SW2
    CMP     R0, #1
    BEQ     FINAL_SAVE          ; Sauvegarde aussi avant le rejeu

    ; 3. COLLISIONS
    BL      READ_BUMP_L
    CMP     R0, #1
    BEQ     RECORD_DROITE

    BL      READ_BUMP_R
    CMP     R0, #1
    BEQ     RECORD_GAUCHE

    B       CHECK_INPUTS

; === SAUVEGARDE ET MOUVEMENTS ===
FINAL_SAVE
    LSL     R5, R4, #1          ; Prend la distance parcourue
    STR     R5, [R11], #4       ; �crit en RAM
    MOV     R4, #0
    B       STOP_ROBOT

RECORD_DROITE
    LSL     R5, R4, #1			; D�calage de 1 bit et stockage dans R5
    BIC     R5, R5, #1			; Mettre le premier bit � 0
    STR     R5, [R11], #4
    MOV     R4, #0
    BL      ACTION_DROITE
    B       exploration_loop

RECORD_GAUCHE
    LSL     R5, R4, #1
    ORR     R5, R5, #1          ; OU logique, met le premier bit � 1 (ici)
    STR     R5, [R11], #4
    MOV     R4, #0
    BL      ACTION_GAUCHE
    B       exploration_loop

STOP_ROBOT
    BL      LED1_OFF
    BL      LED2_OFF
    BL      MOTEUR_DROIT_OFF
    BL      MOTEUR_GAUCHE_OFF
wait_replay
    BL      READ_SW2
    CMP     R0, #1
    BEQ     START_REPLAY
    B       wait_replay

; === PHASE REPLAY ===
START_REPLAY
    BL      MOTEUR_DROIT_ON
    BL      MOTEUR_GAUCHE_ON
    LDR     R10, =PATH_START

replay_step
    CMP     R10, R11
    BEQ     FINISH_REPLAY
    
    LDR     R5, [R10], #4
    MOV     R9, R5, LSR #1      ; Distance � d�compter, un d�calage pour ne pas avoir le bit de direction
    AND     R8, R5, #1          ; Direction

    BL      MOTEUR_DROIT_AVANT
    BL      MOTEUR_GAUCHE_AVANT

count_down
    ; Synchro temporelle avec les lectures mat�rielles pour garder le m�me temps que l'exploration
    BL      READ_SW1
    BL      READ_SW2
    BL      READ_BUMP_L
    BL      READ_BUMP_R
    SUBS    R9, R9, #1
    BNE     count_down

    ; Test fin de parcours ou virage
    CMP     R10, R11
    BEQ     FINISH_REPLAY

    CMP     R8, #1
    BEQ     REPLAY_GAUCHE

REPLAY_DROITE
    BL      ACTION_DROITE
    B       replay_step

REPLAY_GAUCHE
    BL      ACTION_GAUCHE
    B       replay_step

FINISH_REPLAY
    BL      MOTEUR_DROIT_OFF
    BL      MOTEUR_GAUCHE_OFF
    B       wait_replay

; === MOUVEMENTS ===
ACTION_DROITE
    PUSH    {LR}		;Mettre l'adresse du code au sommet de la pile
    BL      LED1_ON             
    BL      MOTEUR_GAUCHE_AVANT
    BL      MOTEUR_DROIT_ARRIERE
    BL      DELAY_90_DEG        
    BL      LED1_OFF            
    POP     {PC}		;R�cup�rer l'adresse du code qui a appel� ACTION_DROITE

ACTION_GAUCHE
    PUSH    {LR}		;Mettre l'adresse du code au sommet de la pile
    BL      LED2_ON             
    BL      MOTEUR_GAUCHE_ARRIERE
    BL      MOTEUR_DROIT_AVANT
    BL      DELAY_90_DEG
    BL      LED2_OFF            
    POP     {PC}		;R�cup�rer l'adresse du code qui a appel� ACTION_GAUCHE

DELAY_90_DEG
    LDR     R0, =0x011FFFFF
l1  SUBS    R0, R0, #1
    BNE     l1
    BX      LR

    END