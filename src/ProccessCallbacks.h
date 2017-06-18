#ifndef PROCCES_CALLBACKS_H
#define PROCCES_CALLBACKS_H

#include <Arduino.h>

struct deviceAttribute {
  int id;
  String name;
  String setValue;
  String currentValue;
};

void attribute1ProccessCallback(deviceAttribute &attribute_state);
void attribute2_proccess_callback(deviceAttribute &attribute_state);

#endif
