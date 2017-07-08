#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"

int initDeviceAttributes(deviceAttribute states[]) {
  // attribute 1 init
  states[0].id = 1;
  states[0].currentValue = 26;

  return 0;
}
