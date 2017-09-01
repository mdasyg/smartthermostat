#include <Arduino.h>

#include "System.h"

void updateQuickButtonsState(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonIndex) {
  byte i;
  if (quickButtons[quickButtonIndex].isInitialized == true) {
    if (quickButtons[quickButtonIndex].isActive == true) {
      quickButtons[quickButtonIndex].isActive = false;
      for (i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
        stateOfAttributes[quickButtons[quickButtonIndex].actions[i].deviceAttributeIndex].setValue = quickButtons[quickButtonIndex].actions[i].endSetValue;
      }
      registerWrite(quickButtonLedIndex[quickButtonIndex], LOW);
    } else {
      for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
        quickButtons[i].isActive = false;
        registerWrite(quickButtonLedIndex[i], LOW);
      }
      quickButtons[quickButtonIndex].isActive = true;
      quickButtons[quickButtonIndex].activiationTimeTimestampInSeconds = millis() / 1000;
      for (i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
        stateOfAttributes[quickButtons[quickButtonIndex].actions[i].deviceAttributeIndex].setValue = quickButtons[quickButtonIndex].actions[i].startSetValue;
      }
      registerWrite(quickButtonLedIndex[quickButtonIndex], HIGH);
    }
  }
}

void checkQuickButtonsStatus(quickButton quickButtons[], deviceAttribute stateOfAttributes[]) {
  byte i;
  for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
    if (quickButtons[i].isInitialized == true) {
      if (quickButtons[i].isActive == true) {
        if ((quickButtons[i].activiationTimeTimestampInSeconds + quickButtons[i].duration) < (millis() / 1000)) {
          updateQuickButtonsState(quickButtons, stateOfAttributes, i);
        }
      }
    }
  }
}
