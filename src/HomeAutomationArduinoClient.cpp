#include <Arduino.h>

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include "DeviceConfigs.h"

#include "ProccessCallbacks.h"

// String postRequestStr;
// String postRequestData;
// char postRequestBuffer[250];
// EthernetClient ethClient;
// PubSubClient mqttClient(ethClient);

deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];

void setup() {

  initDeviceAttributes(stateOfAttributes);

  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);

  Serial.begin(115200);

}

void loop() {

  attribute1ProccessCallback(stateOfAttributes[0]);
  // attribute2_proccess_callback(properties_state[1]);

  Serial.println("Device Status");
  for(int i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
    Serial.print(stateOfAttributes[i].name);
    Serial.print(": Current value = ");
    Serial.print(stateOfAttributes[i].currentValue);
    Serial.print(", Set value = ");
    Serial.print(stateOfAttributes[i].setValue);
    Serial.println();
  }

  Serial.println();

  delay(2000);

}
