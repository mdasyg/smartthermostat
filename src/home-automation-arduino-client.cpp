#include <Arduino.h>
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
unsigned int localPort = 8888;  // local port to listen for UDP packets
bool printResponse = false;
time_t prevDeviceStatusDisplayTime = 0; // when the digital clock was displayed
uint32_t lastAttrUpdateTimestamp;

StaticJsonBuffer<100> jsonBuffer;

uint32_t minDelayBeforeNextDHT22Query_ms;
uint32_t lastDHT22QueryTimestamp;
DHT_Unified dht22(tempSensorPin1, DHTTYPE);

void setup() {
  lastAttrUpdateTimestamp = millis();
  lastDHT22QueryTimestamp = millis();

  Serial.begin(115200);

  /// including DHT sensor

  // initialize the DHT22 sensor
  dht22.begin();

  sensor_t sensor;
  dht22.temperature().getSensor(&sensor);
  Serial.println("------------------------------------");
  Serial.println("Temperature");
  Serial.print  ("Sensor:       "); Serial.println(sensor.name);
  Serial.print  ("Driver Ver:   "); Serial.println(sensor.version);
  Serial.print  ("Unique ID:    "); Serial.println(sensor.sensor_id);
  Serial.print  ("Max Value:    "); Serial.print(sensor.max_value); Serial.println(" *C");
  Serial.print  ("Min Value:    "); Serial.print(sensor.min_value); Serial.println(" *C");
  Serial.print  ("Resolution:   "); Serial.print(sensor.resolution); Serial.println(" *C");
  Serial.print  ("Min Delay:    "); Serial.print(sensor.min_delay); Serial.println(" us");
  Serial.println("------------------------------------");
  // Print humidity sensor details.
  dht22.humidity().getSensor(&sensor);
  Serial.println("------------------------------------");
  Serial.println("Humidity");
  Serial.print  ("Sensor:       "); Serial.println(sensor.name);
  Serial.print  ("Driver Ver:   "); Serial.println(sensor.version);
  Serial.print  ("Unique ID:    "); Serial.println(sensor.sensor_id);
  Serial.print  ("Max Value:    "); Serial.print(sensor.max_value); Serial.println("%");
  Serial.print  ("Min Value:    "); Serial.print(sensor.min_value); Serial.println("%");
  Serial.print  ("Resolution:   "); Serial.print(sensor.resolution); Serial.println("%");
  Serial.print  ("Min Delay:    "); Serial.print(sensor.min_delay); Serial.println(" us");
  Serial.println("------------------------------------");
  // Set delay between sensor readings based on sensor details.
  minDelayBeforeNextDHT22Query_ms = sensor.min_delay / 1000; // return value in microseconds
  Serial.print("Min Delay: "); Serial.print(minDelayBeforeNextDHT22Query_ms); Serial.println(" ms");
  Serial.println("------------------------------------");
  //// DHT

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

  // system callback
  thermostatProccessCallback(stateOfAttributes, dht22, lastDHT22QueryTimestamp, minDelayBeforeNextDHT22Query_ms);

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
    Serial.println(F("MQTT Connection Error when calling loop"));
  }

  // device status update to Serial
  statusUpdateToSerial(prevDeviceStatusDisplayTime);

  // wdt_reset();

}
