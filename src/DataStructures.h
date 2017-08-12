#include <Arduino.h>

#ifndef DATA_STRUCTURES_H
#define DATA_STRUCTURES_H

struct deviceAttribute {
  int id;
  char name[16];
  char setValue[8];
  char currentValue[8];
};

#endif
