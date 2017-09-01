#include <ArduinoJson.h>
#include <MemoryFree.h>

#include "DeviceConfigs.h"
#include "System.h"

IPAddress ntpTimeServer(10, 168, 10, 60); // TODO REMOVE from here
byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED }; // TODO REMOVE from here
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets
// led status
byte ledStatus = 0b00000000;

extern EthernetUDP udpClient;

// ethernet shield initialization
void initEthernetShieldNetwork() {
  byte etherShieldConnectionRetryCount = 0;
  // Serial.println(F("Trying DHCP"));
  bool isEthernetShieldConnected = false;
  do {
    if (Ethernet.begin(mac) == 0) {
      etherShieldConnectionRetryCount++;
      // Serial.println(F("DHCP failed, Retry later"));
      delay(5000);
    } else {
      isEthernetShieldConnected = true;
    }
  } while (!isEthernetShieldConnected && (etherShieldConnectionRetryCount < 10));
  // if(isEthernetShieldConnected) {
  //   Serial.print(F("IP: ")); Serial.println(Ethernet.localIP());
  // } else {
  //   Serial.print(F("Keep going w/o netwrok"));
  // }

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
  sendNTPpacket(ntpTimeServer);
  uint32_t beginWait = millis();
  while (millis() - beginWait < 1500) {
    int size = udpClient.parsePacket();
    if (size >= NTP_PACKET_SIZE) {
      // Serial.println(F("NTP Response"));
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
  return 0; // return 0 if unable to get the time
}

void registerWrite(byte whichPin, byte whihchState) {
  // turn off the output so the pins don't light up
  // while you're shifting bits:
  digitalWrite(latchPin, LOW);
  // turn on the next highest bit in bitsToSend:
  bitWrite(ledStatus, whichPin, whihchState);
  // shift the bits out:
  shiftOut(dataPin, clockPin, LSBFIRST, ledStatus);
  // turn on the output so the LEDs can light up:
  digitalWrite(latchPin, HIGH);
}

// void printDigits(int digits) {
//   // utility for digital clock display: prints preceding colon and leading 0
//   Serial.print(":");
//   if(digits < 10)
//   Serial.print("0");
//   Serial.print(digits);
// }
//
// void digitalClockDisplay(bool brackets) {
//   if(brackets) {
//     Serial.print("[");
//   }
//   Serial.print(day());
//   Serial.print("-");
//   Serial.print(month());
//   Serial.print("-");
//   Serial.print(year());
//   Serial.print(" ");
//   Serial.print(hour());
//   printDigits(minute());
//   printDigits(second());
//   if(brackets) {
//     Serial.print("] ");
//   } else {
//     Serial.println();
//   }
// }

void readUriFromFlash(const char src[], char buf[]) {
  if (strlen_P(src) > FLASH_READ_BUFFER_MAX_SIZE) {
    Serial.println(F("Cannot read from flash, size limit reached"));
    while(true);
  }

  unsigned int i = 0;
  unsigned int buf_index = 0;

  for (i=0; i<strlen_P(apiBaseUrl); i++) {
    buf[buf_index++] = pgm_read_byte_near(apiBaseUrl + i);
  }
  buf[buf_index++] = '/';
  for (i=0; i<strlen(DEVICE_SERIAL_NUMBER); i++) {
   buf[buf_index++] = DEVICE_SERIAL_NUMBER[i];
  }
  for (i=0; i<strlen_P(src); i++) {
    buf[buf_index++] = pgm_read_byte_near(src + i);
  }
  buf[buf_index] = '\0';

  if (buf_index > FLASH_READ_BUFFER_MAX_SIZE) {
    Serial.println(F("Cannot read from flash, size limit reached"));
    while(true);
  }

}

void updateAppropriateEntityFromJsonResponse(byte *payload) {
  StaticJsonBuffer<100> jsonBuffer;

  JsonObject& root = jsonBuffer.parseObject(payload);

  if (!root.success()) {
    Serial.println(F("parseObject() failed"));
    return;
  }

  if(root.containsKey("da")) {
    byte index = root["da"]["idx"];
    stateOfAttributes[index].id = root["da"]["id"];
    // if (strlen(root["da"]["name"]) > 0) {
    //   strcpy(stateOfAttributes[index].name, root["da"]["name"]);
    // }
    if (strlen(root["da"]["set"]) > 0) {
      stateOfAttributes[index].setValue = root["da"]["set"];
    }
  }

  if(root.containsKey("qb")) {
    byte index = root["qb"]["idx"];
    if (quickButtons[index].isInitialized == false) {
      quickButtons[index].actions = (attributeSettings *)malloc(NUMBER_OF_ATTRIBUTES * sizeof(attributeSettings));
      quickButtons[index].isInitialized = true;
    }
    if (strlen(root["qb"]["dur"]) > 0) {
      quickButtons[index].duration = root["qb"]["dur"];
    }
  }

  if(root.containsKey("qb_a")) {
    byte actionIndex = root["qb_a"]["idx"];
    byte deviceAttributeIndex = root["qb_a"]["da_idx"];
    quickButtons[actionIndex].actions[deviceAttributeIndex].deviceAttributeIndex = deviceAttributeIndex;
    quickButtons[actionIndex].actions[deviceAttributeIndex].startSetValue = root["qb_a"]["start"];
    quickButtons[actionIndex].actions[deviceAttributeIndex].endSetValue = root["qb_a"]["end"];
  }
}

void statusUpdateToSerial(time_t &lastDeviceStatusDisplayUpdateTimestamp, deviceAttribute stateOfAttributes[]) {
  // Device status in serial
  if (timeStatus() != timeNotSet) {
    if ((now() - lastDeviceStatusDisplayUpdateTimestamp) >= 5) { // in seconds
      byte i;
      lastDeviceStatusDisplayUpdateTimestamp = now();
      Serial.println();
      Serial.println(now());
      Serial.print(F("Free RAM(bytes): ")); Serial.println(freeMemory());
      for(i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
        Serial.print(stateOfAttributes[i].id);
        Serial.print(F("-> Cur: "));
        Serial.print(stateOfAttributes[i].currentValue);
        Serial.print(F(", Set: "));
        Serial.print(stateOfAttributes[i].setValue);
        Serial.println();
      }
      Serial.println();
    }
  }
}
