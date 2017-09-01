#include <Arduino.h>
#include <dht.h>
#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>
#include <EthernetUdp.h>
#include <TimeLib.h>
#include <avr/wdt.h>
#include <MemoryFree.h>

#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "MqttCallbacks.h"
#include "Requests.h"
#include "System.h"
#include "QuickButtons.h"

// custom data structures
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
quickButton quickButtons[NUMBER_OF_QUICK_BUTTONS];
// buffers
char flashReadBuffer[FLASH_READ_BUFFER_MAX_SIZE];
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
// help vars for button presses
bool stateButtonPressed = false;
bool quickButtonPressed[3] = {false, false, false};

byte i;

void setup() {
  Serial.begin(19200);

  Serial.println("Loading...");

  // boiler pin init
  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);
  // shift register for
  pinMode(latchPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  // button pin init
  pinMode(deviceStateToggleButtonPin, INPUT);
  pinMode(quickButtonsPin[QUICK_BUTTON_1_INDEX], INPUT);
  pinMode(quickButtonsPin[QUICK_BUTTON_2_INDEX], INPUT);
  pinMode(quickButtonsPin[QUICK_BUTTON_3_INDEX], INPUT);

  // initialize led status to all off
  shiftOut(dataPin, clockPin, MSBFIRST, 0b00000000);

  lastAttrUpdateTimestamp = millis();
  lastDHT22QueryTimestamp = millis();
  lastDeviceStatusDisplayUpdateTimestamp = millis();

  // Init EthernetClient
  initEthernetShieldNetwork();
  // Init UDP
  udpClient.begin(localUdpPort);
  // Init NTP system
  setSyncProvider(getNtpTime);
  // Init PubSubClient
  mqttConnectToBrokerCallback(mqttClient);
  // Send device info to application server
  readUriFromFlash(deviceStatsUpdateUri, flashReadBuffer);
  sendDeviceStatsUpdateToApplicationServer(ethClient, flashReadBuffer);
  // initialize device attributes
  stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 0;
  stateOfAttributes[STATE_ATTRIBUTE_INDEX].currentValue = 0;
  // Request devices info initialization and wait the reponse on MQTT
  readUriFromFlash(deviceDataRequestUri, flashReadBuffer);
  sendHttpGetRequest(ethClient, flashReadBuffer, "all");

  // watchdog enable
  wdt_enable(WDTO_2S);
  wdt_reset();

  Serial.print(F("S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("F/W: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

}

time_t heartbeat = now();
long unsigned int loop_counter = 0;

void loop() {
  if ((digitalRead(deviceStateToggleButtonPin) == HIGH)) {
    if (stateButtonPressed == false) {
      stateButtonPressed = true;
      if(stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue == 1) {
        stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 0;
      } else {
        stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 1;
      }
    }
  } else {
    if (stateButtonPressed == true) {
      stateButtonPressed = false;
    }
  }

  for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
    if ((digitalRead(quickButtonsPin[i]) == HIGH)) {
      if (quickButtonPressed[i] == false) {
        quickButtonPressed[i] = true;
        updateQuickButtonsState(quickButtons, stateOfAttributes, i);
      }
    } else {
      if (quickButtonPressed[i] == true) {
        quickButtonPressed[i] = false;
      }
    }
  }

  checkQuickButtonsStatus(quickButtons, stateOfAttributes);

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
    readUriFromFlash(deviceAttributesUpdateUri, flashReadBuffer);
    sendDeviceAtributesStatusUpdateToApplicationServer(ethClient, flashReadBuffer, stateOfAttributes);
    lastAttrUpdateTimestamp = millis();
  }

  Ethernet.maintain();

  mqttClient.loop();

  // device status update to Serial
  // statusUpdateToSerial(lastDeviceStatusDisplayUpdateTimestamp, stateOfAttributes);

  loop_counter++;
  if (now() - heartbeat >= 1) {
    Serial.println(now());
    Serial.print(F("Loop count: ")); Serial.println(loop_counter);
    Serial.print(F("Free RAM(bytes): ")); Serial.println(freeMemory());
    loop_counter = 0;
    heartbeat = now();
  }

  wdt_reset();

}
