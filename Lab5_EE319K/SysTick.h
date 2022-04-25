// SysTick.h
// Runs on TM4C123
// Provide functions that initialize the SysTick module, wait at least a
// designated number of clock cycles, and wait approximately a multiple
// of 10 milliseconds using busy wait.  
// Put your names here
// Last Modified: 1/11/2022


#ifndef __systick_h
#define __systick_h
#include <stdint.h>

// Initialize SysTick with busy wait running at bus clock.
void SysTick_Init(void);

// Time delay using busy wait.
// The delay parameter is in units of the core clock. (units of 12.5 nsec for 80 MHz clock)
void SysTick_Wait(uint32_t delay);

// Time delay using busy wait.
// This assumes 80 MHz system clock.
void SysTick_Wait10ms(uint32_t delay);

#endif
