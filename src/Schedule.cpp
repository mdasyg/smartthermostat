#include "Schedule.h"
#include "System.h"
#include "DeviceConfigs.h"

void checkScheduleStatus(schedule schedules[], deviceAttribute stateOfAttributes[]) {
  byte i;
  for(i=0; i<MAX_NUMBER_OF_SCHEDULES; i++) {
    if(schedules[i].isInitialized == true) {
      if(schedules[i].isActive == true) {
        if (now() >= schedules[i].endTimestamp) {
          schedules[i].isActive = false;
          // call for new schedules...
        }
      } else {
        if (now() >= schedules[i].startTimestamp && now() < schedules[i].endTimestamp) {
          schedules[i].isActive = true;
        }
      }
    }
  }
  return;
}
