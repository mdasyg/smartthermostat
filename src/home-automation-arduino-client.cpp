#include <Arduino.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>
#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <PubSubClient.h>
#include <TimeLib.h>
#include <MemoryFree.h>
#include <ArduinoJson.h>

#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

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
StaticJsonBuffer<100> jsonBuffer;
// clients
EthernetClient ethClient;
EthernetClient ethClientForMqtt;
EthernetUDP udpClient;
PubSubClient mqttClient(mqttServerUrl, mqttServerPort, mqttReceiveMsgCallback, ethClientForMqtt);
bool isEthClientConnectedToServer = false;
// timers
uint32_t lastDHT22QueryTimestamp;
uint32_t lastAttrUpdateTimestamp;
time_t prevDeviceStatusDisplayTime = 0; // when the digital clock was displayed
// DHT
DHT_Unified dht22(tempSensorPin1, DHTTYPE);
uint16_t minDelayBeforeNextDHT22Query_ms;

void setup() {
  Serial.begin(115200);

  flashReadBufferStr.reserve(FLASH_READ_BUFFER_MAX_SIZE);

  lastAttrUpdateTimestamp = millis();
  lastDHT22QueryTimestamp = millis();

  // initialize the DHT22 sensor
  dht22.begin();
  sensor_t sensor;
  dht22.temperature().getSensor(&sensor);
  minDelayBeforeNextDHT22Query_ms = sensor.min_delay / 1000; // return value in microseconds

  initDeviceAttributes(stateOfAttributes);

  intialDeviceInfoToSerial();

  // initial status update
  statusUpdateToSerial(prevDeviceStatusDisplayTime, stateOfAttributes);

  // Init EthernetClient
  initEthernetShieldNetwork();
  // Init UDP
  udpClient.begin(localUdpPort);
  // Init NTP system
  setSyncProvider(getNtpTime);
  // Init PubSubClient
  mqttConnectToBrokerCallback(mqttClient);

  wdt_enable(WDTO_8S);

  // Send device info to application server
  // digitalClockDisplay(true); Serial.println(F("Device Status Update"));
  readFromFlash(deviceStatsUpdateUri, flashReadBufferStr);
  flashReadBufferStr.replace("DEV_UID", DEVICE_SERIAL_NUMBER);
  sendDeviceStatsUpdateToApplicationServer(ethClient, flashReadBufferStr);

}

void loop() {

  if (!mqttClient.connected()) {
    digitalClockDisplay(true); Serial.println(F("Disconected from MQTT broker"));
    mqttConnectToBrokerCallback(mqttClient);
  }

  // ask for data from server
  // buildDeviceAttributesRequest(postRequestData);

  // read server response
  httpResponseReader(ethClient);

  // if the server's disconnected, stop the client:
  if (isEthClientConnectedToServer && !ethClient.connected()) {
    digitalClockDisplay(true); Serial.println(F("Disconnecting from app server"));
    ethClient.stop();
    isEthClientConnectedToServer = false;
  }

  // system callback
  thermostatProccessCallback(stateOfAttributes, dht22, lastDHT22QueryTimestamp, minDelayBeforeNextDHT22Query_ms);

  // Send statistics to app
  if (millis() - lastAttrUpdateTimestamp > attrUpdateInterval ) {
    readFromFlash(deviceAttributesUpdateUri, flashReadBufferStr);
    flashReadBufferStr.replace("DEV_UID", DEVICE_SERIAL_NUMBER);
    sendDeviceAtributesStatusUpdateToApplicationServer(ethClient, flashReadBufferStr, stateOfAttributes);
    lastAttrUpdateTimestamp = millis();
  }

  Ethernet.maintain();

  if (mqttClient.loop() == false) {
    digitalClockDisplay(true); Serial.println(F("MQTT connection error when calling 'MQTT::loop()'"));
  }

  // device status update to Serial
  statusUpdateToSerial(prevDeviceStatusDisplayTime, stateOfAttributes);

  wdt_reset();

}
