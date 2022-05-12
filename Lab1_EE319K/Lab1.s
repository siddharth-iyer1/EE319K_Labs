;****************** Lab1.s ***************
; Program initially written by: Yerraballi and Valvano
; Author: Siddharth Iyer
; Date Created: 1/15/2018 
; Last Modified: 1/28/2022
; Brief description of the program: Solution to Lab1
; The objective of this system is to implement a parity system
; Hardware connections: 
; One output is positive logic, 1 turns on the LED, 0 turns off the LED
; Three inputs are positive logic, meaning switch not pressed is 0, pressed is 1


GPIO_PORTD_DATA_R  EQU 0x400073FC
GPIO_PORTD_DIR_R   EQU 0x40007400
GPIO_PORTD_DEN_R   EQU 0x4000751C
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_DEN_R   EQU 0x4002451C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
       PRESERVE8 
       AREA   Data, ALIGN=4
; No global variables needed

       ALIGN 4
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT EID
EID    DCB "ssi325",0  ; replace abc123 with your EID
       EXPORT RunGrader
	   ALIGN 4
RunGrader DCD 1 ; change to nonzero when ready for grading
           
      EXPORT  Lab1
Lab1 
; Initializations

; Initialize Port D
	LDR R0, =SYSCTL_RCGCGPIO_R
	LDR R1, [R0]
	ORR R1, #0x08	; Sets bit 3 (Port D) to 1, Initializes clock
	STR R1, [R0]
	NOP
	NOP
	
; Set I/O Pins
	LDR R0, =GPIO_PORTD_DIR_R
	MOV R2, #0x20	; Clears input bits and sets output bit - Bit 5
	STR R2, [R0]
	
; Digitally Enabling Pins
	LDR R0, =GPIO_PORTD_DEN_R
	MOV R3, #0x27	; Enables pins 0, 1, 2, and 5
	STR R3, [R0]
	
	
loop
; First begin by storing input Key values into unique registers

	LDR R0, =GPIO_PORTD_DATA_R
	LDR R1, [R0]
	AND R1, #0x01	; R1 = PD0
	LDR R2, [R0]
	AND R2, #0x02	; R2 = PD1
	LDR R3, [R0]
	AND R3, #0x04	; R3 = PD2

; Now we need to shift all the values we are testing to the same bit location
; This way we can perform logic operations on them
	
	LSR R2, R2, #1
	LSR R3, R3, #2

; Next, we perform an EOR check on the PD0 and PD1 values

	EOR R4, R1, R2	; EOR Value (0 or 1) is stored in R4

; Perform another EOR check on the value put into R4 with the PD2 value
; This will be our output value

	EOR R5, R4, R3

; Since our value is in the first bit location (PD0), we need to move it five to the left
; so it can be read by our output pin (PD5)
	
	LSL R5, R5, #5
	
; Perform an STR on R5 and R0 to move our calculated value into the Port Data Register

	STR R5, [R0]

	B    loop


    
    ALIGN        ; make sure the end of this section is aligned
    END          ; end of file
		
		

               
