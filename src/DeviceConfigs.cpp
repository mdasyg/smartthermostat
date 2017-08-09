#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"

int initDeviceAttributes(deviceAttribute states[]) {

  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);

  // attribute 1 init
  states[0].id = 1; // temperature
  states[0].name = F("Temperature");

  // attribute 2 init
  states[1].id = 5; // ON-OFF
  states[1].name = F("ON/OFF");

  // attribute 3 init
  states[2].id = 6; // Humidity
  states[2].name = F("RH");

  return 0;
}
