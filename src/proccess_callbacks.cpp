#include "proccess_callbacks.h"

void attribute1_proccess_callback(device_attribute &attribute_state) {
  Serial.println("Attr 1 proccessing...");

  Serial.println(attribute_state.id);
  Serial.println(attribute_state.name);

  attribute_state.id = 54;

  return;
}
