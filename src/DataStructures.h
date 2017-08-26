#include <Arduino.h>

#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

struct deviceAttribute {
  int id;
  char name[16];
  float setValue;
  float currentValue;
};

#endif
