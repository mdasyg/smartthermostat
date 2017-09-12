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
#include "Schedule.h"

// custom data structures
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];
quickButton quickButtons[NUMBER_OF_QUICK_BUTTONS];
schedule schedules[MAX_NUMBER_OF_SCHEDULES];
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
bool quickButtonPressed[NUMBER_OF_QUICK_BUTTONS] = {false, false, false};

time_t lastHeartbeatTimestamp = now();
long unsigned int loop_counter = 0;

byte i;

void setup() {
  Serial.begin(19200);

  Serial.println("Loading...");

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
  pinMode(deviceStateToggleButtonPin, INPUT);
  pinMode(quickButtonsPin[QUICK_BUTTON_1_INDEX], INPUT);
  pinMode(quickButtonsPin[QUICK_BUTTON_2_INDEX], INPUT);
  pinMode(quickButtonsPin[QUICK_BUTTON_3_INDEX], INPUT);

  // initialize led status to 'all off'
  shiftOut(dataPin, clockPin, MSBFIRST, 0b00000000);

  // init timestamp counters
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
  mqttConnectToBrokerCallback(ethClientForMqtt, mqttClient);
  // Send device info to application server
  readUriFromFlash(deviceStatsUpdateUri, flashReadBuffer);
  sendDeviceStatsUpdateToApplicationServer(ethClient, flashReadBuffer);
  // initialize device attributes
  stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 0;
  stateOfAttributes[STATE_ATTRIBUTE_INDEX].currentValue = 0;
  // Request devices info initialization and wait the reponse on MQTT
  readUriFromFlash(deviceDataRequestUri, flashReadBuffer);
  char queryStringDataTmpBuf[15] = "t=all&sc_s=";
  itoa(MAX_NUMBER_OF_SCHEDULES, &queryStringDataTmpBuf[11], 10);
  sendHttpGetRequest(ethClient, flashReadBuffer, queryStringDataTmpBuf);

  // watchdog enable
  wdt_enable(WDT_TIMEOUT_TIME);
  wdt_reset(); // seems to need that, because restart happened before reaching the end of the first loop.

  Serial.print(F("S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("F/W: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

}

void loop() {

  // check device state button has been pressed
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

  // check for quick button press
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

  // check if some quick button had been pressed and now must stop working
  checkQuickButtonsStatus(quickButtons, stateOfAttributes);

  // check for schedule enable-disable
  checkScheduleStatus(schedules, stateOfAttributes);

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

  // device status update to Serial
  // statusUpdateToSerial(lastDeviceStatusDisplayUpdateTimestamp, stateOfAttributes);

  // ##### HEART BEAT DEVICE STATUSES ##########################################
  // loop_counter++;
  // if (now() - lastHeartbeatTimestamp >= 1) {
  //   Serial.println(now());
  //   // Serial.print(F("Loop count: ")); Serial.println(loop_counter);
    // Serial.print(F("Free RAM(bytes): ")); Serial.println(freeMemory());
  //
  //   // // Quick Buttons
  //   // byte i,j;
  //   // for(i=0; i<NUMBER_OF_QUICK_BUTTONS; i++) {
  //   //   Serial.print("qb: "); Serial.print(i);
  //   //   Serial.print(", dur: "); Serial.print(quickButtons[i].duration);
  //   //   Serial.print(", init?: "); Serial.print(quickButtons[i].isInitialized);
  //   //   Serial.print(", active?: "); Serial.print(quickButtons[i].isActive);
  //   //   Serial.println();
  //   //   for(j=0; j<NUMBER_OF_ATTRIBUTES; j++) {
  //   //     Serial.print("qb_a: "); Serial.print(j);
  //   //     Serial.print(", start: "); Serial.print(quickButtons[i].actions[j].startSetValue);
  //   //     Serial.print(", end: "); Serial.print(quickButtons[i].actions[j].endSetValue);
  //   //     Serial.println();
  //   //   }
  //   // }
  //   // Serial.println();
  //
  //   // Schedules
  //   byte m,n;
  //   for(m=0; m<MAX_NUMBER_OF_SCHEDULES; m++) {
  //     Serial.print("sc: "); Serial.print(m);
  //     Serial.print(", s: "); Serial.print(schedules[m].startTimestamp);
  //     Serial.print(", e: "); Serial.print(schedules[m].endTimestamp);
  //     Serial.print(", r: "); Serial.print(schedules[m].recurrenceFrequency);
  //     Serial.print(", init?: "); Serial.print(schedules[m].isInitialized);
  //     Serial.print(", active?: "); Serial.print(schedules[m].isActive);
  //     Serial.println();
  //     // for(n=0; n<NUMBER_OF_ATTRIBUTES; n++) {
  //     //   Serial.print("qb_a: "); Serial.print(n);
  //     //   Serial.print(", start: "); Serial.print(schedules[m].actions[n].startSetValue);
  //     //   Serial.print(", end: "); Serial.print(schedules[m].actions[n].endSetValue);
  //     //   Serial.println();
  //     // }
  //   }
  //   Serial.println();
  //
  //   loop_counter = 0;
    // lastHeartbeatTimestamp = now();
  // }
  // ##### HEART BEAT DEVICE STATUSES ##########################################

  wdt_reset();

}
