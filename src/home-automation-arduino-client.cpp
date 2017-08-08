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

bool isEthClientConnectedToServer = false;
String postRequestData;
EthernetClient ethClient;
EthernetClient ethClientForMqtt;
EthernetUDP udpClient;
PubSubClient mqttClient(mqttServerUrl, mqttServerPort, mqttReceiveMsgCallback, ethClientForMqtt);
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
unsigned int localUdpPort = 8888;  // local port to listen for UDP packets
bool printResponse = false;
time_t prevDeviceStatusDisplayTime = 0; // when the digital clock was displayed
uint32_t lastAttrUpdateTimestamp;

StaticJsonBuffer<100> jsonBuffer;

uint16_t minDelayBeforeNextDHT22Query_ms;
uint32_t lastDHT22QueryTimestamp;
DHT_Unified dht22(tempSensorPin1, DHTTYPE);

// buffers
char URIBuffer[40];

void readFromFlash(const char *src, char *dest) {
  if (strlen_P(src) > 40) {
    Serial.println(F("URI bigger than the buf. Aborting execution of program"));
    while(true);
  }
  memccpy_P(dest, src, 0, strlen_P(src));
}

void setup() {
  Serial.begin(115200);

  lastAttrUpdateTimestamp = millis();
  lastDHT22QueryTimestamp = millis();

  // initialize the DHT22 sensor
  dht22.begin();
  sensor_t sensor;
  dht22.temperature().getSensor(&sensor);
  minDelayBeforeNextDHT22Query_ms = sensor.min_delay / 1000; // return value in microseconds

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
  udpClient.begin(localUdpPort);
  // Init NTP system
  setSyncProvider(getNtpTime);
  // Init PubSubClient
  mqttConnectToBrokerCallback(mqttClient);
  // Send device info to application server
  digitalClockDisplay(true);
  Serial.println(F("Device Status Update"));
  prepareDeviceStatusRequestData(postRequestData);
  readFromFlash(deviceStatusUri, URIBuffer);
  sendPostRequest(ethClient, URIBuffer, postRequestData);

  // wdt_enable(WDTO_8S);

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
      Serial.println(F("Response Data"));
      printResponse = true;
      counter = 0;
    }
  }

  // if the server's disconnected, stop the client:
  if (isEthClientConnectedToServer && !ethClient.connected()) {
    digitalClockDisplay(true);
    Serial.println(F("Disconnecting"));
    ethClient.stop();
    isEthClientConnectedToServer = false;
  }

  // system callback
  thermostatProccessCallback(stateOfAttributes, dht22, lastDHT22QueryTimestamp, minDelayBeforeNextDHT22Query_ms);

  // Send statistics to app
  if (millis() - lastAttrUpdateTimestamp > attrUpdateInterval ) {
    digitalClockDisplay(true);
    Serial.println(F("Device Attributes Status Update"));
    prepareDeviceAtributesStatusUpdateRequestData(postRequestData, stateOfAttributes);
    readFromFlash(deviceAttributesUpdateUri, URIBuffer);
    sendPostRequest(ethClient, URIBuffer, postRequestData);
    lastAttrUpdateTimestamp = millis();
  }

  Ethernet.maintain();

  if (mqttClient.loop() == false) {
    digitalClockDisplay(true);
    Serial.println(F("MQTT Connection Error when calling loop"));
  }

  // device status update to Serial
  statusUpdateToSerial(prevDeviceStatusDisplayTime);

  // wdt_reset();

}
