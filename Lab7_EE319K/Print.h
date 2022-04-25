// Print.h
// This software has interface for printing
// Runs on TM4C123
// Program written by: put your names here
// Date Created: 
// Last Modified:  
// Lab number: 7

#ifndef PRINT_H
#define PRINT_H
#include <stdint.h>

//-----------------------LCD_OutDec-----------------------
// Output a 32-bit number in unsigned decimal format
// Input: none
// Output: none
// n=0,    then output "0"
// n=3,    then output "3"
// n=89,   then output "89"
// n=123,  then output "123"
// n=9999, then output "9999"
void LCD_OutDec(uint32_t n);

//-----------------------LCD_OutFix-----------------------
// Output a 32-bit number in unsigned fixed-point format, 0.001 format
// Input: none
// Output: none
// n=0,    then output "0.000"
// n=3,    then output "0.003"
// n=89,   then output "0.089"
// n=123,  then output "0.123"
// n=9999, then output "9.999"
// n>9999, then output "*.***"
void LCD_OutFix(uint32_t n);

#endif
