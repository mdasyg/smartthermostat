#include <Arduino.h>
#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "Requests.h"

byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };

// String postRequestStr;
String postRequestData;
EthernetClient ethClient;
// PubSubClient mqttClient(ethClient);

deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];

void setup() {

  Serial.begin(115200);

  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);

  initDeviceAttributes(stateOfAttributes);

  Serial.print(F("Device Name: "));
  Serial.println(DEVICE_FRIENDLY_NAME);
  Serial.print(F("Device S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("Device Firmware: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

  // Init EthernetClient
  Serial.println(F("Trying to get IP from DHCP..."));
  if (Ethernet.begin(mac) == 0) {
    while (1) {
      Serial.println(F("Failed to configure Ethernet using DHCP"));
      delay(10000);
    }
  }
  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());

  // Init PubSubClient

  // Send device info to application server
  //buildDeviceInfoSendRequest(postRequestData);
  //sendPostRequest(ethClient, postRequestData);

sendGetRequest(ethClient);

}

void loop() {

  // ask for data from server
  // buildDeviceAttributesRequest(postRequestData);



  if (ethClient.available()) {
    Serial.println("YES");
    char c = ethClient.read();
    Serial.println(c);
  } else {
    Serial.println("NO");
    delay(5000);
  }

  // attribute1ProccessCallback(stateOfAttributes[0]);
  // // attribute2ProccessCallback(properties_state[1]);
  //
  // Serial.println("Device Status");
  // for(int i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
  //   Serial.print(stateOfAttributes[i].name);
  //   Serial.print(": Current value = ");
  //   Serial.print(stateOfAttributes[i].currentValue);
  //   Serial.print(", Set value = ");
  //   Serial.print(stateOfAttributes[i].setValue);
  //   Serial.println();
  // }
  //
  // Serial.println();
  //
  // delay(2000);


  // Send statistics to app

}
