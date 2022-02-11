// ****************** Lab2.c ***************
// Program written by: Siddharth Iyer
// Date Created: 1/18/2017 
// Last Modified: 1/10/2022
#include "Lab2.h"
// Put your name and EID in the next two lines
char Name[] = "Siddharth Iyer";
char EID[] = "ssi325";
// Brief description of the Lab: 
// An embedded system is capturing data from a
// sensor and performing analysis on the captured data.
//   The three analysis subroutines are:
//    1. Calculate the average error
//    2. Perform a linear equation using integer math 
//    3. Check if the captured readings are a monotonic series
// Possibility 1)
//       Return 1 if the readings are in non-increasing order.
//       Examples:
//         10,9,7,7,5,2,-1,-5 is True=1
//         2,2,2,2 is True=1
//         9,7,7,5,6,-1,-5 is False=0 (notice the increase 5 then 6)
//         3,2,1,0,1 is False (notice the increase 0 then 1)
// Possibility 2)
//       Return 1 if the readings are in non-decreasing order.
//       Examples:
//         -5,-1,2,5,7,7,9,10 is True=1
//         2,2,2,2 is True=1
//         -1,6,5,7,7,9,10 is False=0 (notice the decrease 6 then 5)
//         1,2,3,4,3 is False=0 (notice the decrease 4 then 3)
#include <stdint.h>

// Inputs: Data is an array of 32-bit signed measurements
//         N is the number of elements in the array
// Let x0 be the expected or true value
// Define error as the absolute value of the difference between the data and x0
// Output: Average error
// Notes: you do not need to implement rounding
// The value for your x0 will be displayed in the UART window
int32_t AverageError(const int32_t Readings[], const uint32_t N){

int32_t sum = 0;
int32_t avg_error = 0;
int32_t error = 0;
	
for(uint32_t i = 0; i<N; i++){
	sum += Readings[i];	
	error +=	576;	
}
avg_error = sum;
avg_error -= error;
avg_error = avg_error / N;

return avg_error;
}

// Consider a straight line between two points (x1,y1) and (x2,y2)
// Input: x an integer ranging from x1 to x2 
// Find the closed point (x,y) approximately on the line
// Output: y
// Notes: you do not need to implement rounding
// The values of (x1,y1) and (x2,y2) will be displayed in the UART window
int32_t Linear(int32_t const x){
int32_t y = 0;
	y = x*200;
	return y;
}

// Return 1 or 0 based on whether the readings are a monotonic series
// Inputs: Readings is an array of 32-bit measurements
//         N is the number of elements in the array
// Output: 1 if monotonic, 0 if nonmonotonic
// Whether you need to implement non-increasing or non-decreasing will be displayed in the UART window
int IsMonotonic(int32_t const Readings[], uint32_t const N){

for(uint32_t i=0;i<N-1;i++){
	if(Readings[i] < Readings[i+1])
		return 0;
}
return 1;
}