#include <ArduinoJson.h>
#include <MemoryFree.h>
#include <avr/wdt.h>

#include "DeviceConfigs.h"
#include "System.h"
#include "Schedule.h"
#include "QuickButtons.h"

IPAddress ntpTimeServer(10, 168, 10, 60); // TODO REMOVE from here
byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED }; // TODO REMOVE from here
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets
// led status
byte ledStatus = 0b00000000;

// system buffer for reading form flash
char flashReadBuffer[FLASH_READ_BUFFER_MAX_SIZE];

// ethernet shield initialization
void initEthernetShieldNetwork() {
  // Serial.println(F("Trying DHCP"));
  if (Ethernet.begin(mac) == 0) {
    // Serial.println(F("DHCP failed"));
    while(true);
  } else {
    // Serial.print(F("IP: ")); Serial.println(Ethernet.localIP());
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

void ledStatusShiftRegisterHandler(byte whichPin, byte whihchState) {
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

void setDeviceAttributesValue(attributeSettings actions[], deviceAttribute stateOfAttributes[], bool setStart) {
  byte i, idx;
  for (i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
    float valueToSet;
    if (actions[i].inUse) {
      if (setStart) {
        valueToSet = actions[i].startSetValue;
      } else {
        valueToSet = actions[i].endSetValue;
      }
      idx = actions[i].deviceAttributeIndex;
      if (stateOfAttributes[idx].setValue != valueToSet) {
        stateOfAttributes[idx].setValue = valueToSet;
      }
    }
  }
}

void setAction(attributeSettings &action, byte deviceAttributeIndex, float startValue, float endValue) {
  action.deviceAttributeIndex = deviceAttributeIndex;
  action.startSetValue = startValue;
  action.endSetValue = endValue;
  action.inUse = true;
}

void readUriFromFlash(const char src[], char buf[]) {
  if (strlen_P(src) > FLASH_READ_BUFFER_MAX_SIZE) {
    // Serial.println(F("Cannot read from flash, size limit reached"));
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
    // Serial.println(F("Cannot read from flash, size limit reached"));
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
    if (strlen(root["da"]["set"]) > 0) {
      stateOfAttributes[index].setValue = root["da"]["set"];
    }
  }

  if(root.containsKey("qb")) {
    byte index = root["qb"]["idx"];
    if (index >= NUMBER_OF_QUICK_BUTTONS) {
      return;
    }
    if (quickButtons[index].isInitialized == false) {
      quickButtons[index].actions = (attributeSettings *)calloc(NUMBER_OF_ATTRIBUTES, sizeof(attributeSettings));
      quickButtons[index].isInitialized = true;
    }
    if (strlen(root["qb"]["dur"]) > 0) {
      quickButtons[index].durationMilliSeconds = (uint32_t)root["qb"]["dur"] * 1000;
    }
  }

  if(root.containsKey("sc")) {
    byte index = root["sc"]["idx"];
    if (index >= MAX_NUMBER_OF_SCHEDULES) {
      return;
    }
    if (schedules[index].isInitialized == false) {
      schedules[index].actions = (attributeSettings *)calloc(NUMBER_OF_ATTRIBUTES, sizeof(attributeSettings));
      schedules[index].isInitialized = true;
    }
    if (strlen(root["sc"]["s"]) > 0) {
      schedules[index].startTimestamp = (uint32_t)root["sc"]["s"];
    }
    if (strlen(root["sc"]["e"]) > 0) {
      schedules[index].endTimestamp = (uint32_t)root["sc"]["e"];
    }
    if (strlen(root["sc"]["r"]) > 0) {
      schedules[index].recurrenceFrequency = (uint32_t)root["sc"]["r"];
    }
    if (strlen(root["sc"]["p"]) > 0) {
      schedules[index].priority = (byte)root["sc"]["p"];
    }
  }

  if(root.containsKey("qb_a")) {
    byte quickButtonIndex = root["qb_a"]["idx"];
    byte deviceAttributeIndex = root["qb_a"]["da_idx"];
    if (quickButtonIndex >= NUMBER_OF_QUICK_BUTTONS || deviceAttributeIndex >= NUMBER_OF_ATTRIBUTES) {
      return;
    }
    setAction(quickButtons[quickButtonIndex].actions[deviceAttributeIndex], deviceAttributeIndex, root["qb_a"]["start"], root["qb_a"]["end"]);
  }

  if(root.containsKey("sc_a")) {
    byte scheduleIndex = root["sc_a"]["idx"];
    byte deviceAttributeIndex = root["sc_a"]["da_idx"];
    if (scheduleIndex >= MAX_NUMBER_OF_SCHEDULES || deviceAttributeIndex >= NUMBER_OF_ATTRIBUTES) {
      return;
    }
    setAction(schedules[scheduleIndex].actions[deviceAttributeIndex], deviceAttributeIndex, root["sc_a"]["start"], root["sc_a"]["end"]);
  }

  if(root.containsKey("qb_del")) {
    byte index = root["qb_del"]["idx"];
    if (index >= NUMBER_OF_QUICK_BUTTONS) {
      return;
    }
    disableQuickButton(quickButtons, stateOfAttributes, index);
  }

  if (root.containsKey("sc_del")) {
    byte i;
    for (i=0; i<MAX_NUMBER_OF_SCHEDULES; i++) {
      disableSchedule(schedules, stateOfAttributes, i);
    }
  }

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
