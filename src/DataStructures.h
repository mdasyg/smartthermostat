#include <Arduino.h>

#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

struct deviceAttribute {
  int id;
  String name;
  String setValue;
  String currentValue;
};

#endif
