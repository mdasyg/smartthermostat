#include <avr/pgmspace.h>
#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>

#include "DataStructures.h"

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

const char DEVICE_SERIAL_NUMBER[] =  "973214849367374423"; // BE CAREFUL TO UPDATE DEVICE SERIAL NUMBER
const char DEVICE_FIRMWARE_VERSION[] = "0.0.1";

const char DEVICE_FRIENDLY_NAME[] =  "home-auto-dev534";

const byte NUMBER_OF_ATTRIBUTES = 3; // be carefull to update according of attributes count, and the appropriate constants
const byte STATE_ATTRIBUTE_INDEX = 0;
const byte TEMP_ATTRIBUTE_INDEX = 1;
const byte HUMIDITY_ATTRIBUTE_INDEX = 2;

const char MQTT_USERNAME[] =  "";
const char MQTT_PASSWORD[] = "";

const unsigned long attrUpdateInterval = 10000L; // in milliseconds

const char applicationServerUrl[] = "home-auto.eu";
const unsigned int applicationServerPort = 8080; // to unsigned anevazei poly thn xrhsh tis flash, gt?
const char mqttServerUrl[] = "home-auto.eu";
const unsigned int mqttServerPort = 1883;

const unsigned int localUdpPort = 8888;  // local port to listen for UDP packets

const PROGMEM char deviceDataRequestUri[] = "/api/v1/devices/DEV_UID/get_info?t=";
const PROGMEM char deviceStatsUpdateUri[] = "/api/v1/devices/DEV_UID/stats_update";
const PROGMEM char deviceAttributesUpdateUri[] = "/api/v1/devices/DEV_UID/attributes_status_update";

// system variables
const byte boilerRelayPin = 7;
const byte deviceStatusLedIndex = 7;
const byte tempSensorPin1 = 2;

// device buttons
const byte deviceStateButtonPin = 5;

// Pin configuration for 74HC595 for led controlling
const byte latchPin = 8; //Pin connected to latch pin (ST_CP) of 74HC595
const byte dataPin = 9; //Pin connected to Data in (DS) of 74HC595
const byte clockPin = 3; //Pin connected to clock pin (SH_CP) of 74HC595

void initDeviceAttributes(EthernetClient &ethClient, deviceAttribute stateOfAttributes[]);

#endif
