#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <TimeLib.h>
#include <avr/wdt.h>

#include "DeviceConfigs.h"
#include "DataStructures.h"

#ifndef SYSTEM_TIME_H
#define SYSTEM_TIME_H

// device settings
const char DEVICE_FIRMWARE_VERSION[] = "0.0.1";
const byte WDT_TIMEOUT_TIME = WDTO_8S;
const int timeZone = 3; // Athens with DST enabled
const byte NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
const byte FLASH_READ_BUFFER_MAX_SIZE = 110;

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
