#include <Arduino.h>

#include "System.h"

void updateQuickButtonsState(quickButton quickButtons[], byte quickButtonIndex) {
  byte i;
  if (quickButtons[quickButtonIndex].isActive == true) {
    quickButtons[quickButtonIndex].isActive = false;
    registerWrite(quickButtonLedIndex[quickButtonIndex], LOW);
  } else {
    for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
      quickButtons[i].isActive = false;
      registerWrite(quickButtonLedIndex[i], LOW);
    }
    quickButtons[quickButtonIndex].isActive = true;
    registerWrite(quickButtonLedIndex[quickButtonIndex], HIGH);
  }
}
