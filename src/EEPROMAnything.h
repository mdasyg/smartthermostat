#include <Arduino.h>  // for type definitions
#include <EEPROM.h>

template <class T> int EEPROM_writeAnything(int EEPROMaddress, const T& value) {
  const byte* p = (const byte*)(const void*)&value;
  unsigned int i;
  for (i = 0; i < sizeof(value); i++)
  EEPROM.write(EEPROMaddress++, *p++);
  return i;
}

template <class T> int EEPROM_readAnything(int EEPROMaddress, T& value) {
  byte* p = (byte*)(void*)&value;
  unsigned int i;
  for (i = 0; i < sizeof(value); i++)
  *p++ = EEPROM.read(EEPROMaddress++);
  return i;
}
