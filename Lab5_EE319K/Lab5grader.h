// Lab5grader.h
// Runs on LM4F120/TM4C123
// Periodic timer Timer3A and Timer5A which will interact with debugger and implement logic analyzer 
// It initializes on reset and runs whenever interrupts are enabled
// Jonathan Valvano
// 1/11/2022

/* This example accompanies the book
   "Embedded Systems: Real Time Operating Systems for ARM Cortex M Microcontrollers",
   ISBN: 978-1466468863, Jonathan Valvano, copyright (c) 2022
   Section 6.4.5, Program 6.1

 Copyright 2022 by Jonathan W. Valvano, valvano@mail.utexas.edu
    You may use, edit, run or distribute this file
    as long as the above copyright notice remains
 THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
 OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 For more information about my classes, my research, and my books, see
 http://users.ece.utexas.edu/~valvano/
 */
#include <stdint.h>



// 0 for TExaS oscilloscope on PD3, 
// 1 for PA7-2 logic analyzer A
// 2 for PB6-0 logic analyzer B
// 3 for PC7-4 logic analyzer C
// 4 for PE5-0 logic analyzer E
// 5 for Lab5 grader, 
// 6 for none
enum TExaSmode{
  SCOPE,
  LOGICANALYZERA,
  LOGICANALYZERB,
  LOGICANALYZERC,
  LOGICANALYZERE,
	GRADER,
	NONE
};

// ************TExaS_Init*****************
// Initialize scope or logic analyzer, triggered by periodic timer
// This needs to be called once
// Inputs: Scope or Logic analyzer or Grader or None
// Outputs: none
void TExaS_Init(enum TExaSmode mode);

// ************TExaS_Stop*****************
// Stop the transfer
// Inputs:  none
// Outputs: none
void TExaS_Stop(void);
