;****************** main.s ***************
; Program written by: Jonathan Valvano
; Date Created: 2/14/2017
; Last Modified: 1/10/2022
; You are given a simple embedded system with one input and six outputs. 
; This program runs, but you are asked to add minimally intrusive
; debugging instruments to verify it is running properly. 
; The basic function of the system will be to create white noise
; If the input is low, the program outputs random numbers at random times
; If the input is high, the program outputs a constant value at a regular rate
; It uses a pseudo random number, so data will be the same each time
;   Implement debugging instruments which gather data (state and timing)
;   to verify that the system is functioning as expected.
; System Hardware connections 
;  PD2 is Button input positive logic, add an external button
;  6-bit outputs on PB5-0 (you do not need to add actual hardware)
; Lab 4 debugging output
;  LED output PF1 PF2 or PF3 on Launchpad used as a heartbeat

; Option 1, N = 168, Implement HeartBeat on PF1
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
GPIO_PORTB_DATA_R  EQU 0x400053FC
GPIO_PORTB_DIR_R   EQU 0x40005400
GPIO_PORTB_DEN_R   EQU 0x4000551C
GPIO_PORTD_DATA_R  EQU 0x400073FC
GPIO_PORTD_DIR_R   EQU 0x40007400
GPIO_PORTD_DEN_R   EQU 0x4000751C
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_DEN_R   EQU 0x4002551C
; RAM Area
      AREA   DATA, ALIGN=2
Ran   SPACE  4             

; ROM Area
      AREA   |.text|, CODE, READONLY, ALIGN=2
      IMPORT TExaS_Init
      IMPORT Debug_Init
      IMPORT Debug_Dump 
      IMPORT Debug_ElapsedTime 
      IMPORT Debug_Beat
      THUMB

      ALIGN 4
      EXPORT  Start
Start
      CPSID  I          ; disable interrrupts until initialization complete
      BL   PB50_Init    ; initialize output on PB5-0
      BL   PD2_Init     ; initialize switch input on PD2
      LDR  R1,=Ran      ; R1 points to Ran
      MOV  R0,#3        ; Initial seed ***DO NOT CHANGE THIS SEED***
      STR  R0,[R1]      ; Ran=3
; TExaS_Init sets bus clock at 80 MHz, interrupts, ADC1, TIMER3, TIMER5, and UART0
;***YOU MAY CHANGE THE R0 PARAMETER TO 0,1,2,or 3
      MOV  R0,#2 ;0 for TExaS oscilloscope, 1 for PD3-PB50 logic analyzer, 2 for Lab4 grader, 3 for none
      BL   TExaS_Init   ; enables interrupts, prints the pin selections based on your EID1 EID2
;---Your Initialization------------
      BL   Debug_Init  ; you write this
;**********************
      LDR  R5,=GPIO_PORTB_DATA_R
      LDR  R6,=GPIO_PORTD_DATA_R     
loop  
;----- Your HeartBeat------------
;toggle PF1 or PF2 so LED flashes at 1Hz
      BL   Debug_Beat    ; you write this
;**********************
      LDR  R4,[R6]       ; current value of switch
      ANDS R4,R4,#0x04   ; select just bit 2
      BNE  no            ; skip if pushed
; switch not pressed
      MOV  R8,#0x00      ; bit 6 clear
      BL   Random6       ; R0=0 to 0x3F
      LSL  R0,R0,#4
      ADD  R7,R0,#0x8000 ; R7=0x8000 to 0x83F0 time delay
      BL   Random6       ; R0=0 to 63
      B    out
;switch pressed
no    MOV  R7,#0x8000    ; fixed time
      MOV  R0,#32        ; fixed output
      MOV  R8,#0x40      ; bit 6 high
out
      BL   Wait      
      STR  R0,[R5]      ; output to Port B
;----- Your Debug routine------------
      ORR  R0,R0,R8           ; 7-bit data
      BL   Debug_Dump         ; you write this
      BL   Debug_ElapsedTime  ; you write this
;**********************
      B    loop
;Initialize output interface
PB50_Init
    ; activate clock for Port B
      LDR R1, =SYSCTL_RCGCGPIO_R
      LDR R0, [R1]
      ORR R0, R0, #0x02  ; Clock for B
      STR R0, [R1]
      NOP
      NOP                 ; allow time to finish activating
    ; set direction register
      LDR R1, =GPIO_PORTB_DIR_R
      LDR R0, [R1]
      ORR R0, R0, #0x3F    ; Output on PB0-PB5
      STR R0, [R1]
    ; enable digital port
      LDR R1, =GPIO_PORTB_DEN_R
      LDR R0, [R1]
      ORR R0, R0, #0x3F    ; enable PB5-0
      STR R0, [R1]
      BX  LR

;Initialize switch interface, PD2
PD2_Init
    ; activate clock for Port D
      LDR R1, =SYSCTL_RCGCGPIO_R
      LDR R0, [R1]
      ORR R0, R0, #0x08  ; Clock for D
      STR R0, [R1]
      NOP
      NOP                 ; allow time to finish activating
    ; set direction register
      LDR R1, =GPIO_PORTD_DIR_R
      LDR R0, [R1]
      BIC R0, R0, #0x04    ; Input on PD2
      STR R0, [R1]
    ; 5) enable digital port
      LDR R1, =GPIO_PORTD_DEN_R
      LDR R0, [R1]
      ORR R0, R0, #0x04    ; enable PD2
      STR R0, [R1]
      BX  LR

; time delay about 3cycles*R7
Wait 
      SUBS R7,R7,#1  
      BNE  Wait
      BX   LR
 
     
;------------Random6------------
; Return R0= random number 0 to 63
; Linear congruential generator 
; from Numerical Recipes by Press et al.
Random6 
      LDR R2,=Ran    ; R2 points to Ran
      LDR R0,[R2]  ; R0=Ran
      LDR R1,=1664525
      MUL R0,R0,R1 ; R0 = 1664525*Ran
      LDR R1,=1013904223
      ADD R0,R1    ; 1664525*Ran+1013904223 
      STR R0,[R2]  ; store Ran
      LSR R0,R0,#26 ; returns top 6 bits
      BX  LR     
 
      ALIGN      ; make sure the end of this section is aligned
      END        ; end of file

