#include "DeviceConfigs.h"

#include "ProccessCallbacks.h"

int init_device_attributes(device_attribute states[]) {
  // attribute 1 init
  states[0].id = 85;
  states[0].name = "Temperature";
  // attribute 2 init
  states[1].id = 69;
  states[1].name = "Humidity";

  return 0;
}
