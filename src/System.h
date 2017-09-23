#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <TimeLib.h>
#include <avr/wdt.h>

#include "DataStructures.h"

#ifndef SYSTEM_TIME_H
#define SYSTEM_TIME_H

// device settings
const char DEVICE_FIRMWARE_VERSION[] = "0.0.1";
const unsigned int DEVICE_FIRMWARE_VERSION_NUMBER = 0; // remember to increment by 1, when incrementing the fw version string.
const byte WDT_TIMEOUT_TIME = WDTO_8S;
const int timeZone = 3; // Athens with DST enabled
const byte NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
const byte FLASH_READ_BUFFER_MAX_SIZE = 110;
const byte systemDataStructuresEepromAddressStart = 1;

// Pin configuration for 74HC595 for led controlling
const byte latchPin = 8; //Pin connected to latch pin (ST_CP) of 74HC595
const byte dataPin = 9; //Pin connected to Data in (DS) of 74HC595
const byte clockPin = 3; //Pin connected to clock pin (SH_CP) of 74HC595

// info about device's attributes
const byte NUMBER_OF_ATTRIBUTES = 3; // be carefull to update according of attributes count, and the appropriate constants
const byte STATE_ATTRIBUTE_INDEX = 0;
const byte TEMP_ATTRIBUTE_INDEX = 1;
const byte HUMIDITY_ATTRIBUTE_INDEX = 2;

// schedules
const byte MAX_NUMBER_OF_SCHEDULES = 2;
// schedule inidicator PIN index
const byte scheduleStateLedIndex = 3;

// info about device's quick buttons
const byte NUMBER_OF_QUICK_BUTTONS = 3;
const byte QUICK_BUTTON_1_INDEX = 0;
const byte QUICK_BUTTON_2_INDEX = 1;
const byte QUICK_BUTTON_3_INDEX = 2;
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

// overall device status
const byte deviceStateLedIndex = 7;
const byte deviceStateToggleButtonPin = A0;
// boiler PINs
const byte boilerRelayPin = 7;
// temperature sendor PINs
const byte tempSensorPin1 = 2;

// update interval for device's attributes
const unsigned long attrUpdateInterval = 5000L; // in milliseconds

// global variables
extern EthernetUDP udpClient;
extern deviceAttribute stateOfAttributes[];
extern quickButton quickButtons[];
extern schedule schedules[];

void initEthernetShieldNetwork();
void sendNTPpacket(IPAddress &address);
time_t getNtpTime();
void ledStatusShiftRegisterHandler(byte whichPin, byte whihchState);
void setDeviceAttributesValue(attributeSettings actions[], deviceAttribute stateOfAttributes[], bool setStart);
void setAction(attributeSettings &action, byte deviceAttributeIndex, float startValue, float endValue);
void printDigits(int digits);
void digitalClockDisplay(bool brackets);
void readUriFromFlash(const char src[], char buf[]);
void updateAppropriateEntityFromJsonResponse(byte *payload);

#endif
