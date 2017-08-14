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
      dtostrf(dht22.temperature, 3, 1,attributesStates[0].currentValue);
      dtostrf(dht22.humidity, 3, 1,attributesStates[1].currentValue);
      dtostrf(1, 3, 1,attributesStates[2].currentValue);
    } else {
      Serial.println(F("Error reading temp & RH"));
    }

    lastDHT22QueryTimestamp = millis();
  }

  return 0;
}
