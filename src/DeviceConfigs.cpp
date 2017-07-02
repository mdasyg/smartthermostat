#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"

int initDeviceAttributes(deviceAttribute states[]) {
  // attribute 1 init
  states[0].id = 85;
  states[0].name = "Temperature";
  states[0].setValue = "25";
  states[0].currentValue = "35";
  // attribute 2 init
  states[1].id = 69;
  states[1].name = "Humidity";
  states[1].currentValue = "65";

  return 0;
}
