#include <Arduino.h>

#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

struct deviceAttribute {
  int id;
  char name[20];
  float setValue;
  float currentValue;
};

struct quickButton {
  uint32_t duration;
  uint32_t activiationTimeTimestamp;
  bool isActive;
};

// struct scheduleAttributeSettings {
//   uint16_t deviceAttributeId;
//   float startSetValue;
//   float endtSetValue;
// };
//
// struct schedule {
//   uint32_t startTimestamp;
//   uint32_t endTimestamp;
//   uint32_t recurrenceFrequency;
//   byte status;
//   scheduleAttributeSettings *atrrSettings;
// };
//


#endif
