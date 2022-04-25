// Lab5.c starter program EE319K Lab 5, Spring 2022
// Runs on TM4C123
// Kyle Le, Siddharth Iyer
// Last Modified: 3/8/2021

/* 
   Option B2, connect LEDs to PE5-PE0, switches to PA4-2, walk LED PF321
	 When all inputs true, ... South, Walk, West, South, Walk, West, South, Walk, West, ...


  */
// east/west red light connected to bit 5
// east/west yellow light connected to bit 4
// east/west green light connected to bit 3
// north/south red light connected to bit 2
// north/south yellow light connected to bit 1
// north/south green light connected to bit 0
// pedestrian detector connected to most significant bit (1=pedestrian present)
// north/south car detector connected to middle bit (1=car present)
// east/west car detector connected to least significant bit (1=car present)
// "walk" light connected to PF3-1 (built-in white LED)
// "don't walk" light connected to PF3-1 (built-in red LED)
#include <stdint.h>
#include "SysTick.h"
#include "Lab5grader.h"
#include "../inc/tm4c123gh6pm.h"
// put both EIDs in the next two lines
char EID1[] = "ssi325"; //  ;replace abc123 with your EID
char EID2[] = "kl35298"; //  ;replace abc123 with your EID

void DisableInterrupts(void);
void EnableInterrupts(void);

int main(void){ 
  DisableInterrupts();
  TExaS_Init(GRADER);
  SysTick_Init();   // Initialize SysTick for software waits
  // initialize system
	SYSCTL_RCGCGPIO_R |= 0x0031;
	SysTick_Wait10ms(1); //delay
	
	GPIO_PORTA_DEN_R |= 0x1C;	
	GPIO_PORTE_DEN_R |= 0x3F;
	GPIO_PORTF_DEN_R |= 0x0E;

	GPIO_PORTA_DIR_R &= 0x00;	
	GPIO_PORTE_DIR_R |= 0x3F;
	GPIO_PORTF_DIR_R |= 0x0E; 


	
#define allRed		0
#define northG		1
#define northY		2
#define northR		3
#define eastG			4
#define eastY			5
#define eastR			6
#define pedWalk		7
#define pedRed1		8
#define pedOff1		9
#define pedRed2		10
#define pedOff2		11
#define pedRed3		12
#define pedOff3		13
#define pedRed4		14

struct state{
	uint8_t 	Next[8];
	uint8_t 	outPortE;
	uint8_t 	outPortF;
	uint8_t 	Wait;
};

typedef struct state state_t;

state_t FSM[15] = {
	
	{{allRed,eastG,northG,northG,pedWalk,pedWalk,northG,northG}, 0x24, 0x02, 0x40},
	{{northY,northY,northG,northY,northY,northY,northY,northY}, 0x21, 0x02, 0x40},
	{{northR,northR,northR,northR,northR,northR,northR,northR}, 0x22, 0x02, 0x40},
	{{allRed,eastG,northG,eastG,pedWalk,pedWalk,pedWalk,pedWalk}, 0x24, 0x02, 0x40},
	{{eastY,eastG,eastY,eastY,eastY,eastY,eastY,eastY},0x0C, 0x02, 0x40},
	{{eastR,eastR,eastR,eastR,eastR,eastR,eastR,eastR}, 0x14, 0x02, 0x40},
	{{allRed,eastG,northG,northG,pedWalk,pedWalk,northG,northG}, 0x24, 0x02, 0x40},
	{{pedRed1,pedRed1,pedRed1,pedRed1,pedWalk,pedRed1,pedRed1,pedRed1},0x24, 0x0E, 0x40},
	{{pedOff1,pedOff1,pedOff1,pedOff1,pedOff1,pedOff1,pedOff1,pedOff1},0x24, 0x02, 0x40},
	{{pedRed2,pedRed2,pedRed2,pedRed2,pedRed2,pedRed2,pedRed2,pedRed2},0x24, 0x00, 0x40},
	{{pedOff2,pedOff2,pedOff2,pedOff2,pedOff2,pedOff2,pedOff2,pedOff2},0x24, 0x02, 0x40},
	{{pedRed3,pedRed3,pedRed3,pedRed3,pedRed3,pedRed3,pedRed3,pedRed3},0x24, 0x00, 0x40},
	{{pedOff3,pedOff3,pedOff3,pedOff3,pedOff3,pedOff3,pedOff3,pedOff3},0x24, 0x02, 0x40},
	{{pedRed4,pedRed4,pedRed4,pedRed4,pedRed4,pedRed4,pedRed4,pedRed4}, 0x24, 0x00, 0x40},
	{{allRed,eastG,northG,northG,pedWalk,eastG,northG,eastG},0x24, 0x02, 0x40}

	};
  
  EnableInterrupts(); 

	uint8_t S;  // index to the current state 
	uint8_t Input; 


  S = allRed;

  while(1){
		 // 1) output
    // 2) wait
    // 3) input
    // 4) next
		GPIO_PORTE_DATA_R = FSM[S].outPortE;  // set traffic lights
		GPIO_PORTF_DATA_R = FSM[S].outPortF;
		SysTick_Wait10ms(FSM[S].Wait);
		Input = GPIO_PORTA_DATA_R&0x1C;  // read sensors
		Input = Input>>2;
		S = FSM[S].Next[Input];  
		}
	}




