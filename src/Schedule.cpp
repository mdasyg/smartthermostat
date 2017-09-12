#include "Schedule.h"
#include "System.h"
#include "DeviceConfigs.h"
#include "Requests.h"

void checkScheduleStatus(EthernetClient &ethClient, schedule schedules[], deviceAttribute stateOfAttributes[]) {
  // byte i,j;
  // for(i=0; i<MAX_NUMBER_OF_SCHEDULES; i++) {
  //   if(schedules[i].isInitialized == true) {
  //     if(schedules[i].isActive == true) {
  //       if (now() >= schedules[i].endTimestamp) {
  //         Serial.println("stop sc");
  //         schedules[i].isActive = false;
  //         for (j=0; j<NUMBER_OF_ATTRIBUTES; j++) {
  //           stateOfAttributes[schedules[i].actions[j].deviceAttributeIndex].setValue = schedules[i].actions[j].endSetValue;
  //           // Serial.println(stateOfAttributes[schedules[i].actions[j].deviceAttributeIndex].setValue);
  //         }
  //         ledStatusShiftRegisterHandler(scheduleStateLedIndex, LOW);
  //         // ledStatusShiftRegisterHandler(scheduleStateLedIndex+1, HIGH);
  //         // request new schedule data
  //         char flashReadBuffer[FLASH_READ_BUFFER_MAX_SIZE];
  //         readUriFromFlash(deviceDataRequestUri, flashReadBuffer);
  //         char queryStringDataTmpBuf[15] = "t=sc&sc_s=";
  //         itoa(MAX_NUMBER_OF_SCHEDULES, &queryStringDataTmpBuf[11], 10);
  //         sendHttpGetRequest(ethClient, flashReadBuffer, queryStringDataTmpBuf);
  //       }
  //     } else {
  //       if (now() >= schedules[i].startTimestamp && now() < schedules[i].endTimestamp) {
  //         Serial.println("start sc");
  //         schedules[i].isActive = true;
  //         for (j=0; j<NUMBER_OF_ATTRIBUTES; j++) {
  //           stateOfAttributes[schedules[i].actions[j].deviceAttributeIndex].setValue = schedules[i].actions[j].startSetValue;
  //           // Serial.println(stateOfAttributes[schedules[i].actions[j].deviceAttributeIndex].setValue);
  //         }
  //         ledStatusShiftRegisterHandler(scheduleStateLedIndex, HIGH);
  //         // ledStatusShiftRegisterHandler(scheduleStateLedIndex+1, LOW);
  //       }
  //     }
  //   }
  // }
  return;
}
