#include <avr/pgmspace.h>
#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>

#include "DataStructures.h"

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

// device information
const char DEVICE_SERIAL_NUMBER[] =  "905725254349731219"; // BE CAREFUL TO UPDATE DEVICE SERIAL NUMBER
const char DEVICE_ACCESS_TOKEN[] = "askldjfkl435lkdfj3434oit";

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

// schedules
const byte MAX_NUMBER_OF_SCHEDULES = 4;

// application server information
const char applicationServerUrl[] = "home-auto.eu";
const unsigned int applicationServerPort = 8080; // to unsigned anevazei poly thn xrhsh tis flash, gt?
const char mqttServerUrl[] = "home-auto.eu";
const unsigned int mqttServerPort = 1883;
const unsigned int localUdpPort = 8888;  // local port to listen for UDP packets
const PROGMEM char apiBaseUrl[] = "/api/v1/devices";
const PROGMEM char deviceDataRequestUri[] = "/get_info?";
const PROGMEM char deviceStatsUpdateUri[] = "/stats_update";
const PROGMEM char deviceAttributesUpdateUri[] = "/attributes_status_update";

// Pin configuration for 74HC595 for led controlling
const byte latchPin = 8; //Pin connected to latch pin (ST_CP) of 74HC595
const byte dataPin = 9; //Pin connected to Data in (DS) of 74HC595
const byte clockPin = 3; //Pin connected to clock pin (SH_CP) of 74HC595
// overall device status
const byte deviceStateLedIndex = 7;
const byte deviceStateToggleButtonPin = A0;
// boiler PINs
const byte boilerRelayPin = 7;
// temperature sendor PINs
const byte tempSensorPin1 = 2;
// quick button PINs
const byte quickButtonsPin[NUMBER_OF_QUICK_BUTTONS] = {
  [QUICK_BUTTON_1_INDEX] = A1,
  [QUICK_BUTTON_2_INDEX] = A2,
  [QUICK_BUTTON_3_INDEX] = A3
};
const byte quickButtonLedIndex[NUMBER_OF_QUICK_BUTTONS] = {
  [QUICK_BUTTON_1_INDEX] = 6,
  [QUICK_BUTTON_2_INDEX] = 5,
  [QUICK_BUTTON_3_INDEX] = 4
};
// schedule inidicator PIN index
const byte scheduleStateLedIndex = 3;

#endif
