#include <Arduino.h>

#include "System.h"

void updateQuickButtonsState(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonIndex) {
  if (quickButtons[quickButtonIndex].isInitialized == true) {
    if (quickButtons[quickButtonIndex].isActive == true) {
      setDeviceAttributesValue(quickButtons[quickButtonIndex].actions, stateOfAttributes, false);
      ledStatusShiftRegisterHandler(quickButtonLedIndex[quickButtonIndex], LOW);
      quickButtons[quickButtonIndex].isActive = false;
    } else {
      byte i;
      for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
        quickButtons[i].isActive = false;
        ledStatusShiftRegisterHandler(quickButtonLedIndex[i], LOW);
      }
      quickButtons[quickButtonIndex].activiationTimeTimestampInSeconds = millis() / 1000;
      setDeviceAttributesValue(quickButtons[quickButtonIndex].actions, stateOfAttributes, true);
      ledStatusShiftRegisterHandler(quickButtonLedIndex[quickButtonIndex], HIGH);
      quickButtons[quickButtonIndex].isActive = true;
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

void disableQuickButton(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonIndex) {
  if (quickButtons[quickButtonIndex].isActive == true) {
    setDeviceAttributesValue(quickButtons[quickButtonIndex].actions, stateOfAttributes, false);
    ledStatusShiftRegisterHandler(quickButtonLedIndex[quickButtonIndex], LOW);
    quickButtons[quickButtonIndex].isActive = false;
    quickButtons[quickButtonIndex].isInitialized = false;
    free(quickButtons[quickButtonIndex].actions);
  }
}
