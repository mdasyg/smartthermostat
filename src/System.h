#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <TimeLib.h>
#include <avr/wdt.h>

#include "DeviceConfigs.h"
#include "DataStructures.h"

#ifndef SYSTEM_TIME_H
#define SYSTEM_TIME_H

const char DEVICE_FIRMWARE_VERSION[] = "0.0.1";

const byte WDT_TIMEOUT_TIME = WDTO_8S;

const int timeZone = 0;

const byte NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
const byte FLASH_READ_BUFFER_MAX_SIZE = 110;

extern deviceAttribute stateOfAttributes[];
extern quickButton quickButtons[];
extern schedule schedules[];

void initEthernetShieldNetwork();
void sendNTPpacket(IPAddress &address);
time_t getNtpTime();
void registerWrite(byte whichPin, byte whihchState);
void printDigits(int digits);
void digitalClockDisplay(bool brackets);
void readUriFromFlash(const char src[], char buf[]);
void statusUpdateToSerial(time_t &lastDeviceStatusDisplayUpdateTimestamp, deviceAttribute stateOfAttributes[]);

void updateAppropriateEntityFromJsonResponse(byte *payload);

#endif
