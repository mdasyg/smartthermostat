#include <Arduino.h>

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include "proccess_callbacks.h"

#include "device_configs.h"

String postRequestStr;
String postRequestData;
char postRequestBuffer[250];
EthernetClient ethClient;
PubSubClient mqttClient(ethClient);

device_attribute state_of_attributes[NUMBER_OF_ATTRIBUTES];

int TempSensorPin1 = 2;
int TempSensorPin2 = 5;
int relayPin = 7;
int result;

void setup() {

  init_device_attributes(state_of_attributes);

  // pinMode(relayPin, OUTPUT);
  // digitalWrite(relayPin, HIGH);

  Serial.begin(115200);

  ////// TEST CODE ///////////////////////////////////////////////////////////////
  Serial.println(state_of_attributes[0].id);
  Serial.println(state_of_attributes[0].name);

  Serial.print("Relay pin address: ");
  Serial.println((unsigned int)&state_of_attributes, HEX);
  Serial.println((unsigned int)&state_of_attributes[0], HEX);
  Serial.println((unsigned int)&state_of_attributes[1], HEX);

  ////// TEST CODE ///////////////////////////////////////////////////////////////

}

void loop() {

  attribute1_proccess_callback(state_of_attributes[0]);
  // attribute2_proccess_callback(properties_state[1]);

  Serial.println("Device Status");

  Serial.println(state_of_attributes[0].id);
  Serial.println(state_of_attributes[0].name);

  delay(10000);

}
