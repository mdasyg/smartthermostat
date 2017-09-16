#include <Arduino.h>

#include "QuickButtons.h"
#include "System.h"

void updateQuickButtonsState(quickButton quickButtons[], deviceAttribute stateOfAttributes[], byte quickButtonIndex) {
  if (quickButtons[quickButtonIndex].isInitialized == true) {
    if (quickButtons[quickButtonIndex].isActive == true) {
      // Serial.print("Disable QB: "); Serial.println(quickButtonIndex);
      setDeviceAttributesValue(quickButtons[quickButtonIndex].actions, stateOfAttributes, false);
      ledStatusShiftRegisterHandler(quickButtonLedIndex[quickButtonIndex], LOW);
      quickButtons[quickButtonIndex].isActive = false;
      isQuickButtonActive = false;
    } else {
      // Serial.print("Enabling QB: "); Serial.println(quickButtonIndex);
      byte i;
      for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
        quickButtons[i].isActive = false;
        ledStatusShiftRegisterHandler(quickButtonLedIndex[i], LOW);
      }
      quickButtons[quickButtonIndex].activiationTimeTimestampInMilliSeconds = millis();
      setDeviceAttributesValue(quickButtons[quickButtonIndex].actions, stateOfAttributes, true);
      ledStatusShiftRegisterHandler(quickButtonLedIndex[quickButtonIndex], HIGH);
      quickButtons[quickButtonIndex].isActive = true;
      isQuickButtonActive = true;
      Serial.println(quickButtons[quickButtonIndex].activiationTimeTimestampInMilliSeconds);
      Serial.println(quickButtons[quickButtonIndex].duration);
    }
  }
}

void checkQuickButtonsStatus(quickButton quickButtons[], deviceAttribute stateOfAttributes[]) {
  byte i;
  for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
    if (quickButtons[i].isInitialized == true) {
      if (quickButtons[i].isActive == true) {
        // Serial.println("Check qb");
        // Serial.println(quickButtons[i].activiationTimeTimestampInMilliSeconds);
        // Serial.println(quickButtons[i].duration);
        // Serial.println(millis());
        // Serial.println(millis()/1000);
        // Serial.println();
        if ((quickButtons[i].activiationTimeTimestampInMilliSeconds + quickButtons[i].duration) < millis() ) {
          // Serial.print("Auto-dis QB: "); Serial.println(i);
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
    isQuickButtonActive = true;
  }
  quickButtons[quickButtonIndex].isInitialized = false;
  free(quickButtons[quickButtonIndex].actions);
}
