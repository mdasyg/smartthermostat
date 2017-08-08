#include <MemoryFree.h>

#include "DeviceConfigs.h"
#include "System.h"

IPAddress ntpTimeServer(10, 168, 10, 60); // TODO REMOVE from here
byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED }; // TODO REMOVE from here

const int timeZone = 3; // EEST (includes DST)
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets

extern EthernetUDP udpClient;

// ethernet shield initialization
void initEthernetShieldNetwork() {
  byte etherShieldConnectionRetryCount = 0;
  digitalClockDisplay(true);
  Serial.println(F("Trying DHCP"));
  bool isEthernetShieldConnected = false;
  do {
    if (Ethernet.begin(mac) == 0) {
      etherShieldConnectionRetryCount++;
      digitalClockDisplay(true);
      Serial.println(F("DHCP failed"));
      Serial.println(F("Retry later"));
      delay(5000);
    } else {
      isEthernetShieldConnected = true;
    }
  } while (!isEthernetShieldConnected && (etherShieldConnectionRetryCount < 10));
  digitalClockDisplay(true);
  if(isEthernetShieldConnected) {
    Serial.print(F("IP: "));
    Serial.println(Ethernet.localIP());
  } else {
    Serial.print(F("Keep going w/o netwrok"));
  }
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress &address) {
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;
  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  udpClient.beginPacket(address, 123); //NTP requests are to port 123
  udpClient.write(packetBuffer, NTP_PACKET_SIZE);
  udpClient.endPacket();
}

time_t getNtpTime() {
  while (udpClient.parsePacket() > 0) ; // discard any previously received packets
  Serial.println(F("NTP Request"));
  sendNTPpacket(ntpTimeServer);
  uint32_t beginWait = millis();
  while (millis() - beginWait < 1500) {
    int size = udpClient.parsePacket();
    if (size >= NTP_PACKET_SIZE) {
      Serial.println(F("NTP Response"));
      udpClient.read(packetBuffer, NTP_PACKET_SIZE);  // read packet into the buffer
      unsigned long secsSince1900;
      // convert four bytes starting at location 40 to a long integer
      secsSince1900 =  (unsigned long)packetBuffer[40] << 24;
      secsSince1900 |= (unsigned long)packetBuffer[41] << 16;
      secsSince1900 |= (unsigned long)packetBuffer[42] << 8;
      secsSince1900 |= (unsigned long)packetBuffer[43];
      return secsSince1900 - 2208988800UL + timeZone * SECS_PER_HOUR;
    }
  }
  Serial.println(F("No NTP Response"));
  return 0; // return 0 if unable to get the time
}

void printDigits(int digits) {
  // utility for digital clock display: prints preceding colon and leading 0
  Serial.print(":");
  if(digits < 10)
  Serial.print('0');
  Serial.print(digits);
}

void digitalClockDisplay(bool brackets) {
  if(brackets) {
    Serial.print("[");
  }
  Serial.print(day());
  Serial.print("-");
  Serial.print(month());
  Serial.print("-");
  Serial.print(year());
  Serial.print(" ");
  Serial.print(hour());
  printDigits(minute());
  printDigits(second());
  if(brackets) {
    Serial.print("] ");
  } else {
    Serial.println();
  }
}

void readFromFlash(const char src[], String &flashReadBuffer) {
  if (strlen_P(src) > FLASH_READ_BUFFER_MAX_SIZE) {
    Serial.println(F("Src bigger than the flash buf. Aborting execution of program"));
    while(true);
  }
  // memccpy_P(dest, src, 0, strlen_P(src));

  char tempCharBuffer;
  unsigned int i;
  flashReadBuffer = "";
  for (i=0; i<strlen_P(src); i++) {
      tempCharBuffer = pgm_read_byte_near(src + i);
      flashReadBuffer += tempCharBuffer;
    }

}

void statusUpdateToSerial(time_t &prevDeviceStatusDisplayTime, deviceAttribute stateOfAttributes[]) {
  // Device status in serial
  if (timeStatus() != timeNotSet) {
    if ((now() - prevDeviceStatusDisplayTime) >= 30) { // in seconds
      prevDeviceStatusDisplayTime = now();
      Serial.println(F("\nDevice Status Update"));
      Serial.print(F("Time: "));
      digitalClockDisplay(false);
      Serial.print(F("Free RAM = "));
      Serial.print(freeMemory());
      Serial.println(F(" bytes"));
      for(int i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
        Serial.print(stateOfAttributes[i].name);
        Serial.print(F(": Current value = "));
        Serial.print(stateOfAttributes[i].currentValue);
        Serial.print(F(", Set value = "));
        Serial.print(stateOfAttributes[i].setValue);
        Serial.println();
      }
      Serial.println();
    }
  }
}
