#include <Arduino.h>
#include <avr/pgmspace.h>
#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <PubSubClient.h>
#include <TimeLib.h>
#include <MemoryFree.h>

#include <dht.h>

#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "MqttCallbacks.h"
#include "Requests.h"
#include "System.h"

// device attributesStates
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
// buffers
String flashReadBufferStr;
// clients
EthernetClient ethClient;
EthernetClient ethClientForMqtt;
EthernetUDP udpClient;
PubSubClient mqttClient(mqttServerUrl, mqttServerPort, mqttReceiveMsgCallback, ethClientForMqtt);
bool isEthClientConnectedToServer = false;
// timers
uint32_t lastDHT22QueryTimestamp;
uint32_t lastAttrUpdateTimestamp;
time_t lastDeviceStatusDisplayUpdateTimestamp; // when the digital clock was displayed
// DHT
dht dht22;

void setup() {
  Serial.begin(115200);

  flashReadBufferStr.reserve(FLASH_READ_BUFFER_MAX_SIZE);

  lastAttrUpdateTimestamp = millis();
  lastDHT22QueryTimestamp = millis();
  lastDeviceStatusDisplayUpdateTimestamp = millis();

  initDeviceAttributes(stateOfAttributes);

  Serial.println();
  Serial.println(F("Device Info"));
  Serial.print(F("Name: "));
  Serial.println(DEVICE_FRIENDLY_NAME);
  Serial.print(F("S/N:  "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("F/W:  "));
  Serial.println(DEVICE_FIRMWARE_VERSION);
  Serial.println();

  // initial status update
  statusUpdateToSerial(lastDeviceStatusDisplayUpdateTimestamp, stateOfAttributes);

  // Init EthernetClient
  initEthernetShieldNetwork();
  // Init UDP
  udpClient.begin(localUdpPort);
  // Init NTP system
  setSyncProvider(getNtpTime);
  // Init PubSubClient
  mqttConnectToBrokerCallback(mqttClient);

  // Send device info to application server
  // digitalClockDisplay(true); Serial.println(F("Device Status Update"));
  readFromFlash(deviceStatsUpdateUri, flashReadBufferStr);
  flashReadBufferStr.replace("DEV_UID", DEVICE_SERIAL_NUMBER);
  sendDeviceStatsUpdateToApplicationServer(ethClient, flashReadBufferStr);

}

void loop() {

  if (!mqttClient.connected()) {
    // digitalClockDisplay(true); Serial.println(F("Disconected from MQTT broker"));
    mqttConnectToBrokerCallback(mqttClient);
  }

  // ask for data from server
  // buildDeviceAttributesRequest(postRequestData);

  // read server response
  httpResponseReader(ethClient);

  // if the server's disconnected, stop the client:
  if (isEthClientConnectedToServer && !ethClient.connected()) {
    ethClient.stop();
    isEthClientConnectedToServer = false;
  }

  // system callback
  thermostatProccessCallback(stateOfAttributes, dht22, lastDHT22QueryTimestamp);

  // Send statistics to app
  if (millis() - lastAttrUpdateTimestamp > attrUpdateInterval ) {
    readFromFlash(deviceAttributesUpdateUri, flashReadBufferStr);
    flashReadBufferStr.replace("DEV_UID", DEVICE_SERIAL_NUMBER);
    sendDeviceAtributesStatusUpdateToApplicationServer(ethClient, flashReadBufferStr, stateOfAttributes);
    lastAttrUpdateTimestamp = millis();
  }

  Ethernet.maintain();

  if (mqttClient.loop() == false) {
    // digitalClockDisplay(true); Serial.println(F("MQTT connection error"));
  }

  // device status update to Serial
  statusUpdateToSerial(lastDeviceStatusDisplayUpdateTimestamp, stateOfAttributes);

}
