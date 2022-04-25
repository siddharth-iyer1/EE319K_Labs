// SysTick.c
// Runs on TM4C123
// Put your names here
// Last Modified: 1/11/2022
#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"

// Initialize SysTick with busy wait running at bus clock.
void SysTick_Init(void){
    // EE319K students write this function
	NVIC_ST_CTRL_R = 0;               // disable SysTick during setup

  NVIC_ST_CTRL_R = 0x00000005;      // enable SysTick with core clock
}
// The delay parameter is in units of the 80 MHz core clock. (12.5 ns)
void SysTick_Wait(uint32_t delay){
  NVIC_ST_RELOAD_R = delay-1;  // number of counts to wait

  NVIC_ST_CURRENT_R = 0;       // any value written to CURRENT clears

		 while((NVIC_ST_CTRL_R&0x00010000)==0){ // wait for count flag
	}
}
// 10000us equals 10ms
void SysTick_Wait10ms(uint32_t delay){
    // EE319K students write this function
 uint32_t i;

  for(i=0; i<delay; i++){

    SysTick_Wait(800000);  // wait 10ms

  }
}

