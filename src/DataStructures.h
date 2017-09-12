#include <Arduino.h>

#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

struct deviceAttribute {
  int id;
  float setValue;
  float currentValue;
};

struct attributeSettings {
  bool inUse = false;
  uint16_t deviceAttributeIndex;
  float startSetValue;
  float endSetValue;
};

struct quickButton {
  bool isInitialized = false;
  bool isActive = false;
  uint32_t duration;
  uint32_t activiationTimeTimestampInSeconds;
  attributeSettings *actions;
};

struct schedule {
  bool isInitialized = false;
  bool isActive = false;
  uint32_t startTimestamp;
  uint32_t endTimestamp;
  uint32_t recurrenceFrequency;
  attributeSettings *actions;
};

#endif
