#include <Arduino.h>
#include <dht.h>
#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetUdp.h>
#include <TimeLib.h>

#include <avr/wdt.h>

#include <EEPROMAnything.h>

#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "MqttCallbacks.h"
#include "Requests.h"
#include "System.h"

// custom data structures
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
// schedule scheduleTable[2];
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

  // flashReadBufferStr.reserve(FLASH_READ_BUFFER_MAX_SIZE);

  lastAttrUpdateTimestamp = millis();
  lastDHT22QueryTimestamp = millis();
  lastDeviceStatusDisplayUpdateTimestamp = millis();

  Serial.print(F("Name: "));
  Serial.println(DEVICE_FRIENDLY_NAME);
  Serial.print(F("S/N:  "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("F/W:  "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

  // initial device status update to serial
  // statusUpdateToSerial(lastDeviceStatusDisplayUpdateTimestamp, stateOfAttributes);

  // Init EthernetClient
  initEthernetShieldNetwork();
  // Init UDP
  udpClient.begin(localUdpPort);
  // Init NTP system
  setSyncProvider(getNtpTime);
  // Init PubSubClient
  mqttConnectToBrokerCallback(mqttClient);

  // Send device info to application server
  readFromFlash(deviceStatsUpdateUri, flashReadBufferStr);
  flashReadBufferStr.replace("DEV_UID", DEVICE_SERIAL_NUMBER);
  sendDeviceStatsUpdateToApplicationServer(ethClient, flashReadBufferStr);

  // initial device attributes
  initDeviceAttributes(ethClient, stateOfAttributes);

  wdt_enable(WDTO_8S);
  //
  // Serial.println(sizeof(schedule));
  // Serial.println(sizeof(scheduleTable));
  //
  // scheduleTable[0].startTimestamp = 15454654;
  // scheduleTable[0].endTimestamp = 15464654;
  //
  // Serial.println(scheduleTable[0].endTimestamp);

}

// uint32_t loopTimeCount;
// uint32_t loopTimeStat[3] = {0, 10000, 0}; // 0: current, 1: min, 2:max

void loop() {

  // loopTimeCount = micros();

  if (!mqttClient.connected()) {
    mqttConnectToBrokerCallback(mqttClient);
  }

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

  mqttClient.loop();

  // device status update to Serial
  statusUpdateToSerial(lastDeviceStatusDisplayUpdateTimestamp, stateOfAttributes);

  wdt_reset();

  // loopTimeStat[0] = micros() - loopTimeCount;
  // loopTimeCount = micros();
  // if (loopTimeStat[0] < loopTimeStat[1]) {
  //   loopTimeStat[1] = loopTimeStat[0];
  // }
  // if (loopTimeStat[0] > loopTimeStat[2]) {
  //   loopTimeStat[2] = loopTimeStat[0];
  // }

}
