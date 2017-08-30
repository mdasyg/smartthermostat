#include "DeviceConfigs.h"
#include "DataStructures.h"
#include "ProccessCallbacks.h"
#include "System.h"

uint32_t minDelayBeforeNextDHT22Query_ms = 2000; // in milliseconds
int readDht22Result;

int thermostatProccessCallback(deviceAttribute stateOfAttributes[], dht &dht22, uint32_t &lastDHT22QueryTimestamp) {
  if((millis() - lastDHT22QueryTimestamp) > minDelayBeforeNextDHT22Query_ms) {
    // Get temperature event and print its value.
    readDht22Result = dht22.read22(tempSensorPin1);
    if (readDht22Result == DHTLIB_OK) {
      stateOfAttributes[TEMP_ATTRIBUTE_INDEX].currentValue = dht22.temperature;
      stateOfAttributes[HUMIDITY_ATTRIBUTE_INDEX].currentValue = dht22.humidity;
      // stateOfAttributes[STATE_ATTRIBUTE_INDEX].currentValue = 0;
      // dtostrf(dht22.temperature, 3, 1, stateOfAttributes[0].currentValue);
    }
    lastDHT22QueryTimestamp = millis();
  }

  // heating only for now
  if (stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue == 1) {
    registerWrite(deviceStatusLedIndex, HIGH);
    stateOfAttributes[STATE_ATTRIBUTE_INDEX].currentValue = 1;
    if ((stateOfAttributes[TEMP_ATTRIBUTE_INDEX].currentValue) < (stateOfAttributes[TEMP_ATTRIBUTE_INDEX].setValue - 0.5)) {
      digitalWrite(boilerRelayPin, HIGH);
    } else if (stateOfAttributes[TEMP_ATTRIBUTE_INDEX].currentValue > stateOfAttributes[TEMP_ATTRIBUTE_INDEX].setValue ) {
      digitalWrite(boilerRelayPin, LOW);
    }
  } else {
    registerWrite(deviceStatusLedIndex, LOW);
    stateOfAttributes[STATE_ATTRIBUTE_INDEX].currentValue = 0;
    digitalWrite(boilerRelayPin, LOW);
  }

  return 0;
}
