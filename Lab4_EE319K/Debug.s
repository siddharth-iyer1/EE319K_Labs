;****************** Debug.s ***************
; Program written by: Kyle Le & Siddarth Iyer
; Date Created: 2/14/2017
; Last Modified: 2/22/2022

; You may assume your debug functions have exclusive access to SysTick
; However, please make your PortF initialization/access friendly,
; because you have exclusive access to only one of the PortF pins.

; Your Debug_Init should initialize all your debug functionality
; Everyone writes the same version of Debug_ElapsedTime
; Everyone writes Debug_Beat, but the pin to toggle is revealed in the UART window
; There are four possible versions of Debug_Dump. 
; Which version you implement is revealed in the UART window


; ****************Option 1******************
; This is the second of four possible options
; Input: R0 7-bit strategic information 
; Output: none
; If R0 bit 6 is low, 
; - observe the value in bits 5-0 of R0 (value from 0 to 63): 
;     maintain a histogram recording the number of times each value as occurred
;     since N will be less than 200, no histogram count can exceed the 8-bit 255 maximum,  
; If R0 bit 6 is high,
; - Do nothing

SYSCTL_RCGCGPIO_R  EQU 0x400FE608
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_DEN_R   EQU 0x4002551C
SYSCTL_RCGCTIMER_R EQU 0x400FE604
TIMER2_CFG_R       EQU 0x40032000
TIMER2_TAMR_R      EQU 0x40032004
TIMER2_CTL_R       EQU 0x4003200C
TIMER2_IMR_R       EQU 0x40032018
TIMER2_TAILR_R     EQU 0x40032028
TIMER2_TAPR_R      EQU 0x40032038
TIMER2_TAR_R       EQU 0x40032048
 
; RAM Area
            AREA    DATA, ALIGN=2
;place your debug variables in RAM here
            EXPORT DumpBuf
            EXPORT Histogram
            EXPORT MinimumTime
            EXPORT MaximumTime         
DumpBuf     SPACE 200 ; 200 8-bit I/O values, your N will be less than 200
Histogram   SPACE 64  ; count of the number of times each value has occured
MinimumTime SPACE 4   ; smallest elapsed time between called to Debug_ElapsedTime
MaximumTime SPACE 4   ; largest elapsed time between called to Debug_ElapsedTime
; you will need additional globals, but do not change the above definitions
HistogramSpace	EQU 64
Increment	EQU 0
LastTime	SPACE 4
NowTime		SPACE 4
Calls		SPACE 4
N1			SPACE 4
N2			SPACE 4
M			SPACE 4
ElapsedTime	SPACE 4

			EXPORT HistogramSpace
			EXPORT Increment
			EXPORT LastTime
			EXPORT NowTime
			EXPORT Calls
			EXPORT N1
			EXPORT N2
			EXPORT ElapsedTime
; ROM Area
        EXPORT Debug_Init
        EXPORT Debug_Dump 
        EXPORT Debug_ElapsedTime
        EXPORT Debug_Beat
;-UUU-Import routine(s) from other assembly files (like SysTick.s) here
        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT EID1
EID1    DCB "ssi325",0  ;replace ABC123 with your EID
        EXPORT EID2
EID2    DCB "kl35298",0  ;replace ABC123 with your EID
;---------------Your code for Lab 4----------------
;Debug initialization for all your debug routines
;This is called once by the Lab4 grader to assign points (if you pass #2 into TExaS_Init
;It is later called at the beginning of the main.s
;for options 0 and 2, place 0xFF into each element of DumpBuf
;for options 1 and 3, place 0 into each element of Histogram
; save all registers (not just R4-R11)
; you will need to initialize global variables, Timer2 and Port F here
Debug_Init 
      PUSH {R0,R1,R2,LR}
	  PUSH {R3, R4}
      BL   Timer2_Init ;TIMER2_TAR_R is 32-bit down counter
;you write this
	LDR R0 ,= SYSCTL_RCGCGPIO_R 
	LDR R1, [R0] 
	ORR R1, #0x20
	STR R1, [R0]
	NOP
	NOP
	
	LDR R0,= GPIO_PORTF_DIR_R
	LDR R1, [R0]
	ORR R1, #0x02
	STR R1, [R0]
	
	LDR R0,= GPIO_PORTF_DEN_R
	LDR R1, [R0]
	ORR R1, #0x02
	STR R1, [R0]
	
	LDR R0,= M
	MOV R1, #200
	STR R1, [R0]
	
	LDR R0,= Histogram
	LDR R1,= HistogramSpace
	LDR R2,= Increment
	LDR R3,= 0x00
loop
	STR R3, [R0, R2]
	ADD R2, #0x01
	SUB R1, #0x01
	CMP R1, #0
	BNE loop
	
	LDR R1,= N1
	LDR R12,= 168
	STR R12, [R1]
	
	LDR R1,= N2
	LDR R12,= 168
	STR R12, [R1]
	
	POP{R3, R4}
	POP {R0,R1,R2,PC}
    
; There are four possible options: 0,1,2 or 3
; Debug_Dump is called after every output.
; Stop recording and measuring after N observations
; Don't stop after N calls to Debug_Dump, but stop after N changes to your data structures
; N will be revealed to you in the UART window)
; Save all registers (not just R4-R11)

Debug_Dump ; Debug_Dump has 25 instructions including push/pops. As a result, 25*2 = 50 cycles needed
; If it takes 12.5 ns per cycle, then debug_dump should take 625 ns, or 0.000625 ms per execution.
; Furthermore, if it is 2.5 ms between each calls, then the % overhead will be (0.000625/2.5)*100=0.025% 
      PUSH {R0,R1,R2,R3,R4,R11,R12,LR} 
	  ;you write this
woop
 LDR R12,=N1 ; Sets our counter for N = 168
 LDR R11, [R12]
 LDR R2,=Histogram
check
 CMP R11, #0
 BEQ done
 
 MOV R1, R0 ; Reads input
 MOV R3, R0 ; Stores values of bit 5-0 so we can mask R1
 AND R1, #0x40 ; Mask selects bit 6
 LSR R1, #6 ; Shifts bit 6 to bit 0
 CMP R1, #0 ; Checks if input is low
 BEQ low
 BNE high
low
 ; First we need to record the value of the output - load value into R3
 AND R3, #0x3F ; Mask selects bit 5-0

 ; This will be the index value for our array
 ; Travel to Array[Index]
 ADD R2, R2, R3 ; Adds the output value to the address of the Histogram array
 LDRB R4, [R2] ; Takes histogram value at address into R4 - Ex: if 0x0A has been seen 4 times, R4 now equals 4
 ADD R4, R4, #1 ; Adds 1 into R4 since this output value has been seen
 STRB R4, [R2] ; Stores new histogram value into address  
 
 ; Decrement R12 by 1
 SUB R11, #1
 STR R11, [R12] 
 B done
high
 ; Do nothing
 SUB R11, #1 ; Decrement counter for N
 STR R11, [R12]
 B done
done
 POP {R0,R1,R2,R3,R4,R11,R12,PC}

;assume capture is called about every 2.5ms (real board)
;Let M = number of instructions in your Debug_Dump
;Calculate T = M instructions * 2cycles/instruction * 12.5ns/cycle 
;Calculate intrusiveness is T/2.5ms = ???


; Your Debug_ElapsedTime is called after every output.
; Input: none 
; Output: none
; - observe the current time as a 32-bit unsigned integer: 
;     NowTime = TIMER2_TAR
; - Starting with the second call you will be able to measure elapsed time:
;     calcalate ElapsedTime = LastTime-NowTime (down counter)
;     determine the Minimum and Maximum ElapsedTime
; - Set LastTime = NowTime (value needed for next call)
; - Stop recording after N calls (N revealed to you in the UART window)
; save all registers (not just R4-R11)
NOP
Debug_ElapsedTime 
      PUSH {R0-R4,LR}
	  PUSH {R5,R6}
;you write this
	  LDR R4,= Calls
	  LDR R2, [R4]
	  ADD R2, #0x01
	  STR R2, [R4]
	  LDR R3,= N2
	  CMP R2, R3
	  BEQ done1
	  
	  LDR R5, [R4]
	  CMP R5, #0x01
	  BEQ firstCall
	  
	  LDR R0,= NowTime
      LDR R1,= TIMER2_TAR_R
	  LDR R2, [R1] ; R2 holds NowTime Value = Timer2_TAR_R value
	  STR R2, [R0]
	  
	  LDR R0,= LastTime
	  LDR R3, [R0]
	  SUB R3, R3, R2 ; R3 <--  R3-R2
	  
	  LDR R1,= ElapsedTime
	  STR R3, [R1] ; Stores the result of NowTime-LastTime into ElapsedTime
	 
compare
	LDR R0,= MinimumTime
	LDR R1, [R0] ; R1 has Min Time
	LDR R2 ,= MaximumTime
	LDR R3, [R2] ; R3 has Max Time
	LDR R4,= ElapsedTime
	LDR R5, [R4] ; R5 has the elapsed time currently
	
	CMP R5, R1
	BLS changeMinimum
	CMP R5, R3
	BHS changeMaximum
	B almostDone

changeMinimum
	STR R5, [R0]
	B almostDone
	
changeMaximum
	STR R5, [R2]
	B almostDone

almostDone
	LDR R0,= NowTime
	LDR R1, [R0]
	LDR R2,= LastTime
	STR R1, [R2]
	B done1
	
firstCall
	LDR R0,= TIMER2_TAR_R
	LDR R1, [R0]
	LDR R2,= LastTime
	STR R1, [R2]
	
	LDR R0,= MinimumTime
	STR R1, [R0] 
done1
	  
	  POP {R5,R6}
      POP {R0-R4,PC}
    
; Your Debug_Beat function is called every time through the main loop to
; indicate to the operator if the main program is running (not stuck or dead).
; Inputs: none
; Outputs: none
; However, slow down the flashing so the LED flashes at about 1 Hz. 
; 1Hz means repeating: high for 500ms, low for 500ms
; Basically, toggle an LED every Mth call to your Debug_Beat 
; Find the constant M, so the flashing rate is between 0.5 and 2 Hz.
; The Port F pin you need to use will be revealed to you in the UART window.
; Save all registers (not AAPCS) 
Debug_Beat
      PUSH {R0-R2,LR}
	  PUSH {R6,R7}

	  LDR R6,=M
	  LDR R7, [R6]
	  CMP R7, #0
	  BNE done2
	  
	  ;you write this     
	  LDR R0,=GPIO_PORTF_DATA_R
	  LDR R1, [R0]
	  EOR R1, #0x02		; Toggled LED
	  STR R1, [R0]
	  
	  MOV R8, #200
	  STR R8, [R6]
	  B done3
	  
done2
	  SUB R7, #1
	  STR R7, [R6]

done3
	  

	  POP  {R6,R7}
      POP  {R0-R2,PC}




;------------Timer2_Init------------
; This subroutine is functional and does not need editing
; Initialize Timer2 running at bus clock.
; Make it so TIMER2_TAR can be used as a 32-bit time
; TIMER2_TAR counts down continuously
; Input: none
; Output: none
; Modifies: R0,R1
Timer2_Init
    LDR R1,=SYSCTL_RCGCTIMER_R
    LDR R0,[R1]
    ORR R0,R0,#0x04
    STR R0,[R1]    ; activate TIMER2
    NOP
    NOP
    LDR R1,=TIMER2_CTL_R
    MOV R0,#0x00
    STR R0,[R1]    ; disable TIMER2A during setup
    LDR R1,=TIMER2_CFG_R
    STR R0,[R1]    ; configure for 32-bit mode
    LDR R1,=TIMER2_TAMR_R
    MOV R0,#0x02
    STR R0,[R1]    ; configure for periodic mode, default down-count settings
    LDR R1,=TIMER2_TAILR_R
    LDR R0,=0xFFFFFFFE
    STR R0,[R1]    ; reload value
    LDR R1,=TIMER2_TAPR_R
    MOV R0,#0x00
    STR R0,[R1]    ; no prescale, bus clock resolution
    LDR R1,=TIMER2_IMR_R
    MOV R0,#0x00
    STR R0,[R1]    ; no interrupts
    LDR R1,=TIMER2_CTL_R
    MOV R0,#0x01
    STR R0,[R1]    ; enable TIMER2A
    BX  LR          
  
    ALIGN      ; make sure the end of this section is aligned
    END        ; end of file