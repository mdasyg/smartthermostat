#include "Schedule.h"
#include "System.h"
#include "DeviceConfigs.h"
#include "Requests.h"

void checkScheduleStatus(EthernetClient &ethClient, schedule schedules[], deviceAttribute stateOfAttributes[]) {
  byte i;
  for(i=0; i<MAX_NUMBER_OF_SCHEDULES; i++) {
    if(schedules[i].isInitialized == true) {
      if(schedules[i].isActive == true) {
        if (now() >= schedules[i].endTimestamp) {
          Serial.println("stop sc");

          setDeviceAttributesValue(schedules[i].actions, stateOfAttributes, false);

          ledStatusShiftRegisterHandler(scheduleStateLedIndex, LOW);
          schedules[i].isActive = false;

          // request new schedule data
          readUriFromFlash(deviceDataRequestUri, flashReadBuffer);
          char queryStringDataTmpBuf[15] = "t=sc&sc_s=";
          itoa(MAX_NUMBER_OF_SCHEDULES, &queryStringDataTmpBuf[11], 10);
          sendHttpGetRequest(ethClient, flashReadBuffer, queryStringDataTmpBuf);
        }
      } else {
        if (now() >= schedules[i].startTimestamp && now() < schedules[i].endTimestamp) {
          Serial.println("start sc");

          setDeviceAttributesValue(schedules[i].actions, stateOfAttributes, true);

          ledStatusShiftRegisterHandler(scheduleStateLedIndex, HIGH);
          schedules[i].isActive = true;
        }
      }
    }
  }
  return;
}
