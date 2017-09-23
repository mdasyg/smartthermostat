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
#include "DeviceSecrets.h"
#include "ProccessCallbacks.h"
#include "MqttCallbacks.h"
#include "Requests.h"
#include "System.h"
#include "QuickButtons.h"
#include "Schedule.h"
#include "EEPROMAnything.h"

// custom data structures
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
quickButton quickButtons[NUMBER_OF_QUICK_BUTTONS];
schedule schedules[MAX_NUMBER_OF_SCHEDULES];
// buffers
extern char flashReadBuffer[];
// clients
EthernetClient ethClient;
EthernetClient ethClientForMqtt;
EthernetUDP udpClient;
PubSubClient mqttClient(mqttServerUrl, mqttServerPort, mqttReceiveMsgCallback, ethClientForMqtt);
bool isEthClientConnectedToServer = false;
// timers
uint32_t lastDHT22QueryTimestamp;
uint32_t lastAttrUpdateTimestamp;
// DHT
dht dht22;
// help vars for button presses
bool stateButtonPressed = false;
bool quickButtonPressed[NUMBER_OF_QUICK_BUTTONS] = {false, false, false};
// help vars
bool isQuickButtonActive = false;
time_t lastHeartbeatTimestamp = now();
long unsigned int loop_counter = 0;
byte i;

void setup() {
  Serial.begin(19200);

  Serial.println(F("Loading..."));

  ethClient.setTimeout(2000);
  ethClientForMqtt.setTimeout(2000);

  // boiler pin init
  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);
  // shift register for
  pinMode(latchPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  // button pin init
  pinMode(deviceStateToggleButtonPin, INPUT_PULLUP);
  pinMode(quickButtonsPin[QUICK_BUTTON_1_INDEX], INPUT_PULLUP);
  pinMode(quickButtonsPin[QUICK_BUTTON_2_INDEX], INPUT_PULLUP);
  pinMode(quickButtonsPin[QUICK_BUTTON_3_INDEX], INPUT_PULLUP);

  // initialize led status to 'some on' to indicate device loading status
  shiftOut(dataPin, clockPin, MSBFIRST, 0b10101000);

  // init timestamp counters
  lastAttrUpdateTimestamp = millis();
  lastDHT22QueryTimestamp = millis();

  // Init EthernetClient
  initEthernetShieldNetwork();
  // Init UDP
  udpClient.begin(localUdpPort);
  // Init NTP system
  setSyncProvider(getNtpTime);
  // Init PubSubClient
  mqttConnectToBrokerCallback(ethClientForMqtt, mqttClient);
  // Send device info to application server
  readUriFromFlash(deviceStatsUpdateUri, flashReadBuffer);
  sendDeviceStatsUpdateToApplicationServer(ethClient, flashReadBuffer);
  // initialize device attributes
  stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 0;
  stateOfAttributes[STATE_ATTRIBUTE_INDEX].currentValue = 0;
  // Request devices info initialization and wait the reponse on MQTT
  readUriFromFlash(deviceDataRequestUri, flashReadBuffer);
  sendHttpGetRequest(ethClient, flashReadBuffer, "t=all");

  // watchdog enable
  wdt_enable(WDT_TIMEOUT_TIME);
  wdt_reset(); // seems to need that, because restart happened before reaching the end of the first loop.

  // initialize led status to 'all of' to indicate device init complete
  shiftOut(dataPin, clockPin, MSBFIRST, 0b00000000);

  Serial.print(F("S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("F/W: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

}

void loop() {

  // check device state button has been pressed
  if ((digitalRead(deviceStateToggleButtonPin) == LOW)) {
    if (stateButtonPressed == false) {
      stateButtonPressed = true;
    }
  } else {
    if (stateButtonPressed == true) {
      stateButtonPressed = false;
      if(stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue == 1) {
        stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 0;
      } else {
        stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 1;
      }
    }
  }

  // check for quick button press
  for (i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
    if ((digitalRead(quickButtonsPin[i]) == LOW)) {
      if (quickButtonPressed[i] == false) {
        quickButtonPressed[i] = true;
      }
    } else {
      if (quickButtonPressed[i] == true) {
        quickButtonPressed[i] = false;
        updateQuickButtonsState(quickButtons, stateOfAttributes, i);
      }
    }
  }

  // check if some quick button had been pressed and now must stop working
  checkQuickButtonsStatus(quickButtons, stateOfAttributes);

  // check for schedule enable-disable
  if (isQuickButtonActive == false) {
    checkScheduleStatus(ethClient, schedules, stateOfAttributes);
  }

  // mqtt connect to broker
  if (!mqttClient.connected()) {
    mqttConnectToBrokerCallback(ethClientForMqtt, mqttClient);
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

  // ##### HEART BEAT DEVICE STATUSES ##########################################
  // loop_counter++;
  // byte i,j;
  // if (now() - lastHeartbeatTimestamp >= 5) {
  // Serial.println(now());
  //   Serial.print(F("Loop count: ")); Serial.println(loop_counter);
  // Serial.print(F("Free RAM(bytes): ")); Serial.println(freeMemory());
  //
  // // Quick Buttons
  // for(i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
  //   Serial.print("qb: "); Serial.print(i);
  //   Serial.print(", dur: "); Serial.print(quickButtons[i].durationMilliSeconds);
  //   Serial.print(", init?: "); Serial.print(quickButtons[i].isInitialized);
  //   Serial.print(", active?: "); Serial.print(quickButtons[i].isActive);
  //   Serial.println();
  // for(j=0; j<NUMBER_OF_ATTRIBUTES; j++) {
  //   Serial.print("qb_a: "); Serial.print(j);
  //   Serial.print(", start: "); Serial.print(quickButtons[i].actions[j].startSetValue);
  //   Serial.print(", end: "); Serial.print(quickButtons[i].actions[j].endSetValue);
  //   Serial.println();
  // }
  // }
  // Serial.println();
  //
  //   // Schedules
  //   for(i=0; i<MAX_NUMBER_OF_SCHEDULES; i++) {
  //     Serial.print("sc: "); Serial.print(i);
  //     Serial.print(", s: "); Serial.print(schedules[i].startTimestamp);
  //     Serial.print(", e: "); Serial.print(schedules[i].endTimestamp);
  //     Serial.print(", r: "); Serial.print(schedules[i].recurrenceFrequency);
  //     Serial.print(", init?: "); Serial.print(schedules[i].isInitialized);
  //     Serial.print(", active?: "); Serial.print(schedules[i].isActive);
  //     Serial.println();
  //     for(j=0; j<NUMBER_OF_ATTRIBUTES; j++) {
  //       Serial.print("sc_a: "); Serial.print(j);
  //       Serial.print(", start: "); Serial.print(schedules[i].actions[j].startSetValue);
  //       Serial.print(", end: "); Serial.print(schedules[i].actions[j].endSetValue);
  //       Serial.println();
  //     }
  //   }
  //   Serial.println();
  //
  //
  // Device attributes
  // for(i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
  //   Serial.print(F("ID: "));
  //   Serial.print(stateOfAttributes[i].id);
  //   // Serial.print(F(", Cur: "));
  //   // Serial.print(stateOfAttributes[i].currentValue);
  //   Serial.print(F(", Set: "));
  //   Serial.print(stateOfAttributes[i].setValue);
  //   Serial.println();
  // }
  // Serial.println();
  // 
  //   loop_counter = 0;
  // lastHeartbeatTimestamp = now();
  // }
  // ##### HEART BEAT DEVICE STATUSES ##########################################

  wdt_reset();

}
