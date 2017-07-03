#include <Arduino.h>
#include <avr/wdt.h>
#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <PubSubClient.h>
#include <TimeLib.h>
#include <MemoryFree.h>

#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "MqttCallbacks.h"
#include "Requests.h"
#include "SystemTime.h"

byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };
bool isEthClientConnectedToServer = false;
String postRequestData;
EthernetClient ethClient;
EthernetClient ethClientForMqtt;
EthernetUDP udpClient;
PubSubClient mqttClient(mqttServerUrl, mqttServerPort, mqttReceiveMsgCallback, ethClientForMqtt);
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
unsigned int localPort = 8888;  // local port to listen for UDP packets
int respLen = 0;
int counter = 0;
bool printResponse = false;
time_t prevDisplay = 0; // when the digital clock was displayed
unsigned long lastAttrUpdateTimestamp;
unsigned long loopCycleTimer;

void setup() {
  // wdt_enable(WDTO_8S);
  lastAttrUpdateTimestamp = millis();

  Serial.begin(115200);

  Serial.print("Free RAM = ");
  Serial.println(freeMemory());

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
  digitalClockDisplay(true);
  Serial.println(F("Trying to get IP from DHCP..."));
  if (Ethernet.begin(mac) == 0) {
    while (1) {
      digitalClockDisplay(true);
      Serial.println(F("Failed to configure Ethernet using DHCP."));
      Serial.println(F("Please reboot."));
      delay(10000);
    }
  }
  digitalClockDisplay(true);
  Serial.print("My IP address: ");
  Serial.println(Ethernet.localIP());
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

  if (timeStatus() != timeNotSet) {
    if ((now() - prevDisplay) >= 30) {
      prevDisplay = now();
      digitalClockDisplay(false);

      Serial.print("Free RAM = ");
      Serial.println(freeMemory());

      Serial.println(ethClient.getSocketNumber());
      Serial.println(ethClientForMqtt.getSocketNumber());

    }
  }

  // ask for data from server
  // buildDeviceAttributesRequest(postRequestData);

  printResponse = false;
  while (ethClient.available()) {
    char c = ethClient.read();
    if(printResponse) {
      Serial.print(c);
      respLen++;
    }
    if (c == '\r' || c == '\n') {
      counter++;
    } else {
      counter = 0;
    }
    if (counter == 4) {
      Serial.println(F("Molis teliwsan ta headers"));
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

  // wdt_reset();

}
