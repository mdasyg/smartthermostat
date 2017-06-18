#include "DeviceConfigs.h"
#include "DataStructures.h"
#include "ProccessCallbacks.h"

double tempSensorVoltage;
double temperatureCelsius;

int attribute1ProccessCallback(deviceAttribute &attributeState) {
  Serial.print("Proccess for attribute: ");
  Serial.println(attributeState.name);

  tempSensorVoltage = analogRead(tempSensorPin1);

  Serial.print("Volts: ");
  Serial.println(tempSensorVoltage);
  temperatureCelsius = 0.08 * tempSensorVoltage;
  Serial.print("Celius: ");
  Serial.println(temperatureCelsius);

  if(temperatureCelsius < attributeState.setValue.toFloat()) {
    digitalWrite(boilerRelayPin, HIGH);
  } else {
    digitalWrite(boilerRelayPin, LOW);
  }

  attributeState.currentValue = temperatureCelsius;

  return 0;
}
