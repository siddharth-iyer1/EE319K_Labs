// FiFo.c
// Runs on LM4F120/TM4C123
// Provide functions that implement the Software FiFo Buffer
// Last Modified: 11/11/2021 
// Student names: change this to your names or look very silly
#include <stdint.h>

// Declare state variables for FiFo
//        size, buffer, put and get indexes
#define FIFO_Size 8
int32_t static FIFO[FIFO_Size];
int32_t static getI;
int32_t static putI;


// *********** FiFo_Init**********
// Initializes a software FIFO of a
// fixed size and sets up indexes for
// put and get operations
void Fifo_Init() {
//Complete this
	getI = 0;
	putI = 0;
}

// *********** FiFo_Put**********
// Adds an element to the FIFO
// Input: Character to be inserted
// Output: 1 for success and 0 for failure
//         failure is when the buffer is full
uint32_t Fifo_Put(char data){
  //Complete this routine
	if(getI!=((putI+1)%FIFO_Size)){
		FIFO[putI] = data;
		putI= (putI+1)%FIFO_Size;
		return 1;
	}
	else{
		return 0;
	}
}


// *********** Fifo_Get**********
// Gets an element from the FIFO
// Input: Pointer to a character that will get the character read from the buffer
// Output: 1 for success and 0 for failure
//         failure is when the buffer is empty
uint32_t Fifo_Get(char *datapt){
	if(putI != getI){
		*datapt = FIFO[getI];
		getI=(getI+1)%FIFO_Size;
		return 1;
	}
	
	else{
		return 0;
	}
}



