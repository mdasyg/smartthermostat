#include "DeviceConfigs.h"
#include "DataStructures.h"
#include "ProccessCallbacks.h"

int thermostatProccessCallback(deviceAttribute attributesStates[], DHT_Unified &dht22, uint32_t &lastDHT22QueryTimestamp, uint32_t minDelayBeforeNextDHT22Query_ms) {
  if((millis() - lastDHT22QueryTimestamp) > minDelayBeforeNextDHT22Query_ms) {
    // Get temperature event and print its value.
    sensors_event_t event;
    dht22.temperature().getEvent(&event);
    if (isnan(event.temperature)) {
      Serial.println(F("Error reading temperature"));
    } else {
      Serial.print(F("Temperature: "));
      Serial.print(event.temperature);
      Serial.println(F(" *C"));

      attributesStates[0].currentValue = event.temperature;
    }

    // Get humidity event and print its value.
    dht22.humidity().getEvent(&event);
    if (isnan(event.relative_humidity)) {
      Serial.println(F("Error reading humidity"));
    } else {
      Serial.print(F("Humidity: "));
      Serial.print(event.relative_humidity);
      Serial.println('%');

      // attributesStates[2].currentValue = event.relative_humidity;
    }
  }

  lastDHT22QueryTimestamp = millis();

  // if(temperatureCelsius < attributeState.setValue.toFloat()) {
  //   digitalWrite(boilerRelayPin, HIGH);
  // } else {
  //   digitalWrite(boilerRelayPin, LOW);
  // }
  //
  // attributeState.currentValue = temperatureCelsius;

  return 0;
}
