#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"

void initDeviceAttributes(deviceAttribute stateOfAttributes[]) {

  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);

  // attribute 1 init
  stateOfAttributes[0].id = 1; // temperature
  stateOfAttributes[0].name = F("Temperature");

  // attribute 2 init
  stateOfAttributes[1].id = 5; // ON-OFF
  stateOfAttributes[1].name = F("ON/OFF");

  // attribute 3 init
  stateOfAttributes[2].id = 6; // Humidity
  stateOfAttributes[2].name = F("RH");

  return;
}
