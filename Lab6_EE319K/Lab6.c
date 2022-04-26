// Lab6.c
// Runs on TM4C123
// Use SysTick interrupts to implement a 4-key digital piano
// EE319K lab6 starter
// Program written by: put your names here
// Date Created: 3/6/17 
// Last Modified: 1/11/22  
// Lab number: 6
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********


#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"
#include "Sound.h"
#include "Key.h"
#include "Music.h"
#include "Lab6Grader.h"
// put both EIDs in the next two lines
char EID1[] = "ssi325"; //  ;replace abc123 with your EID
char EID2[] = "kl35298"; //  ;replace abc123 with your EID

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void DAC_Init(void);          // your lab 6 solution
void DAC_Out(uint8_t data);   // your lab 6 solution
uint8_t Testdata;

// lab video Lab6_voltmeter, Program 6.1
// A simple program that outputs sixteen DAC values. Use this main if you have a voltmeter.

/*
 Lab 6, Spring 2022, EID1=SSI325, EID2=KL35298
Key3=PE3, Key2=PE2, Key1=PE1, Key0=PE0, DAC=PB5-0
Key0=277.2, Key1=349.2, Key2=415.3, Key3=466.2 Hz


*/
const uint32_t Inputs[16]={0,1,7,8,15,16,17,18,31,32,33,47,48,49,62,63};
int voltmetermain(void){ uint32_t i;  
  DisableInterrupts();
  TExaS_Init(SCOPE);    
  LaunchPad_Init();
  DAC_Init(); // your lab 6 solution
  i = 0;
  EnableInterrupts();
  while(1){                
    Testdata = Inputs[i];
    DAC_Out(Testdata); // your lab 6 solution
    i=(i+1)&0x0F;  // <---put a breakpoint here
  }
}

// DelayMs
//  - busy wait n milliseconds
// Input: time to wait in msec
// Outputs: none
void static DelayMs(uint32_t n){
  volatile uint32_t time;
  while(n){
    time = 6665;  // 1msec, tuned at 80 MHz
    while(time){
      time--;
    }
    n--;
  }
}

void Heartbeat(void)
{
	GPIO_PORTF_DATA_R ^= 0x02;
}


int main(void){       
  DisableInterrupts();
  TExaS_Init(SCOPE);    // bus clock at 80 MHz
  Key_Init();
  LaunchPad_Init();
  Sound_Init();
  Music_Init();
  EnableInterrupts();
  while(1){                
    Heartbeat();
		int key = Key_In();	// This gives us which key has been pressed - our index for which frequency to use
		
		if(key == 0x01){
			Sound_Start(4509);	
		}
		if(key == 0x02){
			Sound_Start(3579);	
		}
		if(key == 0x04){
			Sound_Start(3009);	
		}
		if(key == 0x08){
			Sound_Start(2681);	
		}
		else{
			Sound_Start(0);
		}
		
  }             
}


