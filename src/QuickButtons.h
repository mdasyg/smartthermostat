#include <Arduino.h>

#include "DataStructures.h"

#ifndef QUICK_BUTTONS_H
#define QUICK_BUTTONS_H

void updateQuickButtonsState(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonLedIndex);

#endif
