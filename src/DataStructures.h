#include <Arduino.h>

#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

struct deviceAttribute {
  int id;
  char name[15];
  char setValue[10];
  String currentValue;
};

#endif
