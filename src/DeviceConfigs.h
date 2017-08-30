#include <avr/pgmspace.h>
#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>

#include "DataStructures.h"

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

const char DEVICE_FRIENDLY_NAME[] =  "home-auto-dev534"; // paizete, ipo elegxo

// device information
const char DEVICE_SERIAL_NUMBER[] =  "973214849367374423"; // BE CAREFUL TO UPDATE DEVICE SERIAL NUMBER
const char DEVICE_FIRMWARE_VERSION[] = "0.0.1";

// info about  device's attributes
const byte NUMBER_OF_ATTRIBUTES = 3; // be carefull to update according of attributes count, and the appropriate constants
const byte STATE_ATTRIBUTE_INDEX = 0;
const byte TEMP_ATTRIBUTE_INDEX = 1;
const byte HUMIDITY_ATTRIBUTE_INDEX = 2;

// info about device's quick buttons
const byte NUMBER_OF_QUICK_BUTTONS = 3;
const byte QUICK_BUTTON_1_INDEX = 0;
const byte QUICK_BUTTON_2_INDEX = 1;
const byte QUICK_BUTTON_3_INDEX = 2;

// mqtt ifno
const char MQTT_USERNAME[] =  "";
const char MQTT_PASSWORD[] = "";

// update internal for device's attributes
const unsigned long attrUpdateInterval = 10000L; // in milliseconds

// application server information
const char applicationServerUrl[] = "home-auto.eu";
const unsigned int applicationServerPort = 8080; // to unsigned anevazei poly thn xrhsh tis flash, gt?
const char mqttServerUrl[] = "home-auto.eu";
const unsigned int mqttServerPort = 1883;
const unsigned int localUdpPort = 8888;  // local port to listen for UDP packets
const PROGMEM char deviceDataRequestUri[] = "/api/v1/devices/DEV_UID/get_info?t=";
const PROGMEM char deviceStatsUpdateUri[] = "/api/v1/devices/DEV_UID/stats_update";
const PROGMEM char deviceAttributesUpdateUri[] = "/api/v1/devices/DEV_UID/attributes_status_update";

// overall device status
const byte deviceStatusLedIndex = 7;
const byte deviceStateToggleButtonPin = A0;
// Pin configuration for 74HC595 for led controlling
const byte latchPin = 8; //Pin connected to latch pin (ST_CP) of 74HC595
const byte dataPin = 9; //Pin connected to Data in (DS) of 74HC595
const byte clockPin = 3; //Pin connected to clock pin (SH_CP) of 74HC595
// boiler PINs
const byte boilerRelayPin = 7;
// temperature sendor PINs
const byte tempSensorPin1 = 2;
// quick button PINs
const byte quickButton1Pin = A1;
const byte quickButton2Pin = A2;
const byte quickButton3Pin = A3;
const byte quickButtonLedStatusIndex[NUMBER_OF_QUICK_BUTTONS] = {
  [QUICK_BUTTON_1_INDEX] = 6,
  [QUICK_BUTTON_2_INDEX] = 5,
  [QUICK_BUTTON_3_INDEX] = 4
};

void initDeviceAttributes(EthernetClient &ethClient, deviceAttribute stateOfAttributes[]);

#endif
