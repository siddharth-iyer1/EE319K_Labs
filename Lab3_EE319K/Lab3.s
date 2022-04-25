;****************** Lab3.s ***************
; Program written by: Kyle Le & Siddarth Iyer
; Date Created: 2/4/2017
; Last Modified: 2/12/2022
; Brief description of the program
;   The LED toggles at 2 Hz and a varying duty-cycle
; Hardware connections (External: Two buttons and one LED)
;  Change is Button input  (1 means pressed, 0 means not pressed)
;  Breathe is Button input  (1 means pressed, 0 means not pressed)
;  LED is an output (1 activates external LED)
; Overall functionality of this system is to operate like this
;   1) Make LED an output and make Change and Breathe inputs.
;   2) The system starts with the the LED toggling at 2Hz,
;      which is 2 times per second with a duty-cycle of 30%.
;      Therefore, the LED is ON for 150ms and off for 350 ms.
;   3) When the Change button is pressed-and-released increase 
;      the duty cycle by 20% (modulo 100%). Therefore for each
;      press-and-release the duty cycle changes from 30% to 70% to 70%
;      to 90% to 10% to 30% so on
;   4) Implement a "breathing LED" when Breathe Switch is pressed:
; PortE device registers
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_DEN_R   EQU 0x4002451C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

        IMPORT  TExaS_Init
        THUMB
        AREA    DATA, ALIGN=2
;global variables go here

TIMEON 	SPACE 4
TIMEOFF	SPACE 4
TIMEINC	EQU 2000000
TIMEMAX	EQU 9000000
BREATHEON	SPACE 4
BREATHEOFF	SPACE 4
BREATHEINC	EQU 10000

		
		EXPORT TIMEON
		EXPORT TIMEOFF
		EXPORT TIMEINC
		EXPORT TIMEMAX

		   
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT EID1
EID1   DCB "ssi325",0  ;replace ABC123 with your EID
       EXPORT EID2
EID2   DCB "kl35298",0  ;replace ABC123 with your EID


       ALIGN 4

     EXPORT  Start
; Change - PE1
; Breathe - PE2
; LED - PE4

Start
; TExaS_Init sets bus clock at 80 MHz, interrupts, ADC1, TIMER3, TIMER5, and UART0
     MOV R0,#2  ;0 for TExaS oscilloscope, 1 for PORTE logic analyzer, 2 for Lab3 grader, 3 for none
     BL  TExaS_Init ;enables interrupts, prints the pin selections based on EID1 EID2
 ; Your Initialization goes here
	LDR R0 ,= SYSCTL_RCGCGPIO_R 
	LDR R1, [R0] 
	ORR R1, #0x10
	STR R1, [R0]
	NOP
	NOP
	
	LDR R0,= GPIO_PORTE_DIR_R
	LDR R1, [R0]
	ORR R1, #0x10
	STR R1, [R0]
	
	LDR R0,= GPIO_PORTE_DEN_R
	LDR R1, [R0]
	ORR R1, #0x16
	STR R1, [R0]
	
	LDR R1,= 3000000 ; Initializes to 30% duty cycle
	LDR R0,= TIMEON
	STR R1, [R0]
	
	LDR R1,= 7000000
	LDR R0,= TIMEOFF
	STR R1, [R0]
	
	LDR R9,= 50000000
loop  
; main engine goes here
	LDR R0,= GPIO_PORTE_DATA_R
	LDR R7, [R0]
	AND R8, R7, #0x02
	CMP R8, #0x02 ; Checks if Bit 1 is set (PE1/Change switch)
	BEQ change
return	
	AND R8, R7, #0x04
	CMP R8, #0x04 ; Checks if Bit 2 is set for Breathe Button
	BEQ breathe
	
return1
	LDR R2,= TIMEON
	LDR R3, [R2]
	LDR R4,= TIMEOFF
	LDR R5, [R4]
	
	LDR R1, [R0] ; Turns on LED
	ORR R1, #0x10
	STR R1, [R0]
	BL delay1
	
	EOR R1, #0x10 ; Turns off LED
	STR R1, [R0]
	BL delay2
	
	B loop

change
	LDR R7, [R0]
	AND R7, #0x02
	CMP R7, #0x02 ; Checks if Button has been released, if it hasn't keep looping
	BEQ change
	LDR R3, [R2] ; Loads in amount of time LED is on
	LDR R5, [R4] ; Loads in amount of time LED is off
	LDR R6,= TIMEINC
	LDR R8,= TIMEMAX
	CMP R3, R8 ; Checks if the duty cycle is at 90%
	BEQ backto1 ; If so, branch.
	ADD R3, R6   ; Increments time on
	STR R3, [R2]
	SUB R5, R6 ; Decrements Time off
	STR R5, [R4]
ret	B return

backto1
	LDR R1,= 1000000 ; Puts Time On back to a Duty Cycle of 10%
	STR R1, [R2]
	LDR R1 ,= 9000000 ; Puts time Off to duty cylce of 10%
	STR R1, [R4]
	B ret
	
delay1
	SUBS R3, #1 ; Subtracts from R3, contains Breathe Time On if taken from BReathe, contains Time On if taken from main loop
	BNE delay1
	BX LR
	
delay2
	SUBS R5, #1 ; Subtracts from R5, contains Breathe Time off if taken from Breathe, contains Time off if taken from main loop
	BNE delay2
	BX LR
	


breathe
	LDR R2 ,= BREATHEON ; Breathe Button initialization values
	LDR R1 ,= 10000 ; Time on Value
	STR R1, [R2] ; R2 contains address of BREATHEON
	LDR R4 ,= BREATHEOFF
	LDR R1 ,= 90000 ; Time off value
	STR R1, [R4] ; R4 contains address of BREATHEOFF
	LDR R8 ,= BREATHEINC ; Increment value
	MOV R10, #0x00 ; R10 determines if we are breathing up or we are breathing down
	
resetTimer
	LDR R9,= 10
	
breatheLoop
	LDR R7, [R0] ; Loads in Data Register
	AND R7, #0x04
	CMP R7, #0x04 ; Checks if Breathe Button PE2 has been released, if it has, return back
	BNE return1
	
	LDR R1, [R4] ; Loads in Breathe Time Off, if it is 0 then that means duty cycle is at 100%
	CMP R1, #0x00 ; Checks if duty cycle is at 100%
	BEQ breatheDown ; Reverses the breathing
	
	LDR R1, [R2] ; Loads in Breathe Time Off, it is 0 that means duty cycle is at 0%
	CMP R1, #0x00
	BEQ breatheUp;

	LDR R3, [R2] ; Puts Breathe On into R3
	LDR R5, [R4] ; Puts Breathe Off into R5
	
	LDR R1, [R0] 
	ORR R1, #0x10 ; Turn on LED
	STR R1, [R0]
	BL delay1
	
	EOR R1, #0x10 ; Toggle off LED
	STR R1, [R0]
	BL delay2
	
	SUB R9, R9, #0x01 ; Time for how long each duty cycle runs
	CMP R9, #0x00
	BNE breatheLoop
	
	CMP R10, #0x01
	BEQ breatheDown

breatheUp
	BL toggleBreatheUp
	LDR R1, [R2] ; Loads in Breathe Time On
	ADD R1, R8 ; Increments Breathe Time On
	STR R1, [R2]
	LDR R1, [R4]  ; Loads in Breathe Time Off
	SUB R1, R8 ; Decrements Breathe time off
	STR R1, [R4]
	B resetTimer

breatheDown
	BL toggleBreatheDown
	LDR R1, [R2] ; Loads in Breathe Time On
	SUB R1, R8 ; Decrements Breathe Time On
	STR R1, [R2]
	LDR R1, [R4]  ; Loads in Breathe Time Off
	ADD R1, R8 ; Increments Breathe time off
	STR R1, [R4]
	B resetTimer

toggleBreatheDown
	ORR R10, #0x01
	BX LR

toggleBreatheUp
	MOV R10, #0x00
	BX LR
	
	
	


     ALIGN      ; make sure the end of this section is aligned
     END        ; end of file

