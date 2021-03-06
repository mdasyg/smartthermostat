#include <Arduino.h>

#include "DataStructures.h"

#ifndef QUICK_BUTTONS_H
#define QUICK_BUTTONS_H

extern bool isQuickButtonActive;

void powerOffSchedule(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonIndex);
void updateQuickButtonsState(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonIndex);
void checkQuickButtonsStatus(quickButton quickButtons[], deviceAttribute stateOfAttributes[]);
void disableQuickButton(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonIndex);

#endif
