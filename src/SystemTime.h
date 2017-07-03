#include <Arduino.h>

#include <Ethernet.h>
#include <EthernetUdp.h>
#include <TimeLib.h>

#ifndef SYSTEM_TIME_H
#define SYSTEM_TIME_H

const int NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message

extern EthernetUDP udpClient;

void sendNTPpacket(IPAddress &address);
time_t getNtpTime();
void printDigits(int digits);
void digitalClockDisplay(bool brackets);

#endif
