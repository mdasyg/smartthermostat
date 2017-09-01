#include <Arduino.h>

#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

struct deviceAttribute {
  int id;
  // char name[20];
  float setValue;
  float currentValue;
};

struct attributeSettings {
  uint16_t deviceAttributeIndex;
  float startSetValue;
  float endSetValue;
};

struct quickButton {
  uint32_t duration;
  uint32_t activiationTimeTimestampInSeconds;
  attributeSettings *actions;
  bool isInitialized = false;
  bool isActive = false;
};

struct schedule {
  uint32_t startTimestamp;
  uint32_t endTimestamp;
  uint32_t recurrenceFrequency;
  byte status;
  attributeSettings *action;
};

#endif
