// IO.c
// This software configures the switch and LED
// You are allowed to use any switch and any LED, 
// although the Lab suggests the SW1 switch PF4 and Red LED PF2
// Runs on TM4C123
// Program written by: put your names here
// Date Created: March 30, 2018
// Last Modified:  change this or look silly
// Lab number: 7


#include "../inc/tm4c123gh6pm.h"
#include <stdint.h>

void Wait10ms(uint32_t delay){
	volatile uint32_t time;
  time = 6665*10*delay;  // 1msec*10*delay, tuned at 80 MHz
  while(time){
		time--;
  }
}

//------------IO_Init------------
// Initialize GPIO Port for a switch and an LED
// Input: none
// Output: none
void IO_Init(void) {
 // --UUU-- Code to initialize PF4 and PF2
	SYSCTL_RCGCGPIO_R |= 0x21; //init Port F
	Wait10ms(1);
	GPIO_PORTF_LOCK_R = 0x4C4F434B; // Unlock PORTF
	GPIO_PORTF_CR_R = 0x14; //allow changes to PF4 and PF2
	GPIO_PORTF_AMSEL_R = 0x00; //disable analog
	GPIO_PORTF_AFSEL_R = 0x00; //disablt alt functionality
	GPIO_PORTF_DEN_R |= 0x14;
	// pf4 = switch input, pf2 = led output
	GPIO_PORTF_PCTL_R = 0x00000000; //PCTL GPIO on pf4-0
	GPIO_PORTF_PUR_R = 0x14;
	GPIO_PORTF_DIR_R |= 0x04;
	
}

//------------IO_HeartBeat------------
// Toggle the output state of the  LED.
// Input: none
// Output: none
void IO_HeartBeat(void) {
 // --UUU-- PF2 is heartbeat
	GPIO_PORTF_DATA_R ^= 0x04;
}


//------------IO_Touch------------
// wait for release and press of the switch
// Delay to debounce the switch
// Input: none
// Output: none
void IO_Touch(void) {
 // --UUU-- wait for release; delay for 20ms; and then wait for press
	while((GPIO_PORTF_DATA_R & 0x10)==0x10){};

	Wait10ms(2);
	
	while((GPIO_PORTF_DATA_R & 0x10)==0x00){};
		
}  


