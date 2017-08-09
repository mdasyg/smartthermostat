#include <avr/pgmspace.h>
#include <Arduino.h>
#include <EthernetUdp.h>

#include "DataStructures.h"

#ifndef DHTTYPE
#define DHTTYPE DHT22     // DHT 22 (AM2302)
#endif

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

const char DEVICE_SERIAL_NUMBER[] =  "113702278392778921";
const char DEVICE_FIRMWARE_VERSION[] = "0.0.1";
const char DEVICE_FRIENDLY_NAME[] =  "home-auto-dev534";

const char NUMBER_OF_ATTRIBUTES = 1;

const char MQTT_USERNAME[] =  "asdf";
const char MQTT_PASSWORD[] = "foobar";

const unsigned int attrUpdateInterval = 30000L; // in milliseconds

const char applicationServerUrl[] = "home-auto.eu";
const int applicationServerPort = 1026; // to unsigned anevazei poly thn xrhsh tis flash, gt?
const char mqttServerUrl[] = "home-auto.eu";
const int mqttServerPort = 1883;

const PROGMEM char deviceStatusUri[] = "/api/v1/devices/DEV_UID/status";
const PROGMEM char deviceAttributesUpdateUri[] = "/api/v1/devices/DEV_UID/attributes_status";

// system variables
const int boilerRelayPin = 7;
const int tempSensorPin1 = 2;

int initDeviceAttributes(deviceAttribute states[]);

#endif
