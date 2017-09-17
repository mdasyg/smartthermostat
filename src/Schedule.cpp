#include "Schedule.h"
#include "System.h"
#include "DeviceConfigs.h"
#include "Requests.h"

int activeSchedule = -1;

void powerOffSchedule(schedule schedules[], deviceAttribute stateOfAttributes[], byte scheduleIndex) {
  setDeviceAttributesValue(schedules[scheduleIndex].actions, stateOfAttributes, false);
  ledStatusShiftRegisterHandler(scheduleStateLedIndex, LOW);
  schedules[scheduleIndex].isActive = false;
  activeSchedule = -1;
}

void checkScheduleStatus(EthernetClient &ethClient, schedule schedules[], deviceAttribute stateOfAttributes[]) {
  byte i;
  for(i=0; i<MAX_NUMBER_OF_SCHEDULES; i++) {
    if(schedules[i].isInitialized == true) {

      if(schedules[i].isActive == true) {
        if (now() >= schedules[i].endTimestamp) {
          powerOffSchedule(schedules, stateOfAttributes, i);
          // request new schedule data
          readUriFromFlash(deviceDataRequestUri, flashReadBuffer);
          sendHttpGetRequest(ethClient, flashReadBuffer, "t=sc");
        }
      }

      if ( (now() >= schedules[i].startTimestamp) && (now() < schedules[i].endTimestamp) ) {
        if ( (activeSchedule == -1) || ((activeSchedule > -1) && (schedules[i].priority < schedules[activeSchedule].priority)) ) {
          setDeviceAttributesValue(schedules[i].actions, stateOfAttributes, true);
          ledStatusShiftRegisterHandler(scheduleStateLedIndex, HIGH);
          schedules[i].isActive = true;
          activeSchedule = i;
        }
      }

      if (activeSchedule == i) {
        setDeviceAttributesValue(schedules[i].actions, stateOfAttributes, true);
      }

    }
  }
  return;
}

void disableSchedule(schedule schedules[], deviceAttribute stateOfAttributes[], byte scheduleIndex) {
  if (schedules[scheduleIndex].isActive == true) {
    powerOffSchedule(schedules, stateOfAttributes, scheduleIndex);
  }
  schedules[scheduleIndex].isInitialized = false;
  free(schedules[scheduleIndex].actions);
}
