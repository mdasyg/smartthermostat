#include "DeviceConfigs.h"
#include "DataStructures.h"
#include "ProccessCallbacks.h"
#include "System.h"

uint32_t minDelayBeforeNextDHT22Query_ms = 2000; // in milliseconds
int readDht22Result;

int thermostatProccessCallback(deviceAttribute attributesStates[], dht &dht22, uint32_t &lastDHT22QueryTimestamp) {
  if((millis() - lastDHT22QueryTimestamp) > minDelayBeforeNextDHT22Query_ms) {
    // Get temperature event and print its value.
    readDht22Result = dht22.read22(tempSensorPin1);
    if (readDht22Result == DHTLIB_OK) {
       attributesStates[0].currentValue = dht22.temperature;
       attributesStates[1].currentValue = dht22.humidity;
       attributesStates[2].currentValue = 1;
      // dtostrf(dht22.temperature, 3, 1, attributesStates[0].currentValue);
      // dtostrf(dht22.humidity, 3, 1, attributesStates[1].currentValue);
      // dtostrf(1, 3, 1, attributesStates[2].currentValue);
    }
    lastDHT22QueryTimestamp = millis();
  }

  // heating only for now
  if (attributesStates[0].currentValue < attributesStates[0].setValue) {
    digitalWrite(boilerRelayPin, HIGH);
  } else {
    digitalWrite(boilerRelayPin, LOW);
  }

  return 0;
}
