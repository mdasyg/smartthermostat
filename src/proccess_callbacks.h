#ifndef PROCCES_CALLBACKS_H
#define PROCCES_CALLBACKS_H

#include <Arduino.h>

struct device_attribute {
  int id;
  String name;
  String set_value;
  String current_value;
};

void attribute1_proccess_callback(device_attribute &attribute_state);
void attribute2_proccess_callback(device_attribute &attribute_state);

#endif
