#include <stdint.h>
// 0 for TExaS oscilloscope, 1 for PD2-PB50 logic analyzer, 2 for Lab4 grader, 3 for none
enum TExaSmode{
  SCOPE,
  LOGICANALYZER,
	GRADER,
	NONE
};

// ************TExaS_Init*****************
// Initialize scope or logic analyzer, triggered by periodic timer
// This needs to be called once
// Inputs: Scope or Logic analyzer
// Outputs: none
void TExaS_Init(enum TExaSmode mode);

// ************TExaS_Stop*****************
// Stop the transfer
// Inputs:  none
// Outputs: none
void TExaS_Stop(void);
