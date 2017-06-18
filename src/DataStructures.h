#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

#include <Arduino.h>

struct deviceAttribute {
  int id;
  String name;
  String setValue;
  String currentValue;
};

#endif
