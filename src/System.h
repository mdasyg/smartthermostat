#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <TimeLib.h>

#include "DeviceConfigs.h"
#include "DataStructures.h"

#ifndef SYSTEM_TIME_H
#define SYSTEM_TIME_H

const int timeZone = 3; // EEST (includes DST)

const byte NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
const byte FLASH_READ_BUFFER_MAX_SIZE = 100;

extern deviceAttribute stateOfAttributes[];
extern quickButton quickButtons[];

void initEthernetShieldNetwork();
void sendNTPpacket(IPAddress &address);
time_t getNtpTime();
void registerWrite(byte whichPin, byte whihchState);
void printDigits(int digits);
void digitalClockDisplay(bool brackets);
void readFromFlash(const char src[], char buf[]);
void intialDeviceInfoToSerial();
// void statusUpdateToSerial(time_t &lastDeviceStatusDisplayUpdateTimestamp, deviceAttribute stateOfAttributes[], const uint32_t loopTimeStat[]);
// void statusUpdateToSerial(time_t &lastDeviceStatusDisplayUpdateTimestamp, deviceAttribute stateOfAttributes[]);

void updateAppropriateEntityFromJsonResponse(byte *payload);

#endif
