#include <Arduino.h>
#include <avr/wdt.h>
#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <PubSubClient.h>
#include <TimeLib.h>
#include <MemoryFree.h>
#include <ArduinoJson.h>

#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "MqttCallbacks.h"
#include "Requests.h"
#include "System.h"

bool isEthClientConnectedToServer = false;
String postRequestData;
EthernetClient ethClient;
EthernetClient ethClientForMqtt;
EthernetUDP udpClient;
PubSubClient mqttClient(mqttServerUrl, mqttServerPort, mqttReceiveMsgCallback, ethClientForMqtt);
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
unsigned int localPort = 8888;  // local port to listen for UDP packets
bool printResponse = false;
time_t prevDeviceStatusDisplayTime = 0; // when the digital clock was displayed
unsigned long lastAttrUpdateTimestamp;

StaticJsonBuffer<100> jsonBuffer;

void setup() {
  // wdt_enable(WDTO_8S);
  lastAttrUpdateTimestamp = millis();

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
  Serial.print(F("Free RAM = "));
  Serial.print(freeMemory());
  Serial.println(F(" kb"));

  // Init EthernetClient
  initEthernetShieldNetwork();
  // Init UDP
  udpClient.begin(localPort);
  // Init NTP system
  setSyncProvider(getNtpTime);
  // Init PubSubClient
  mqttConnectToBrokerCallback(mqttClient);
  // Send device info to application server
  digitalClockDisplay(true);
  Serial.println(F("Device Info Status Update"));
  prepareDeviceStatusRequestData(postRequestData);
  sendPostRequest(ethClient, deviceStatusUrl, postRequestData);

}

void loop() {

  if (!mqttClient.connected()) {
    digitalClockDisplay(true);
    Serial.println(F("Disconected from MQTT broker"));
    mqttConnectToBrokerCallback(mqttClient);
  }

  // ask for data from server
  // buildDeviceAttributesRequest(postRequestData);

  // reads server response
  printResponse = false;
  byte counter = 0;
  while (ethClient.available()) {
    char c = ethClient.read();
    if(printResponse) {
      Serial.print(c);
    }
    if (c == '\r' || c == '\n') {
      counter++;
    } else {
      counter = 0;
    }
    if (counter == 4) {
      digitalClockDisplay(true);
      Serial.println(F("Response Data..."));
      printResponse = true;
      counter = 0;
    }
  }

  // if the server's disconnected, stop the client:
  if (isEthClientConnectedToServer && !ethClient.connected()) {
    digitalClockDisplay(true);
    Serial.println(F("Disconnecting..."));
    ethClient.stop();
    isEthClientConnectedToServer = false;
  }

  // attribute1ProccessCallback(stateOfAttributes[0]);
  // // attribute2ProccessCallback(properties_state[1]);
  //

  // Send statistics to app
  if (millis() - lastAttrUpdateTimestamp > attrUpdateInterval ) {
    digitalClockDisplay(true);
    Serial.println(F("Device Attributes Status Update"));
    prepareDeviceAtributesStatusUpdateRequestData(postRequestData, stateOfAttributes);
    sendPostRequest(ethClient, deviceAttributesUpdateUrl, postRequestData);
    lastAttrUpdateTimestamp = millis();
  }

  Ethernet.maintain();

  if (mqttClient.loop() == false) {
    digitalClockDisplay(true);
    Serial.println(F("MQTT Connection Error when calling loop."));
  }

  // device status update to Serial
  statusUpdateToSerial(prevDeviceStatusDisplayTime);


  // wdt_reset();

}
