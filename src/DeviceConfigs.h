#include <avr/pgmspace.h>
#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>

#include "DataStructures.h"

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

const char DEVICE_SERIAL_NUMBER[] =  "753693990288223146";
const char DEVICE_FIRMWARE_VERSION[] = "0.0.1";
const char DEVICE_FRIENDLY_NAME[] =  "home-auto-dev534";

const byte NUMBER_OF_ATTRIBUTES = 3;

const char MQTT_USERNAME[] =  "";
const char MQTT_PASSWORD[] = "";

const unsigned long attrUpdateInterval = 30000L; // in milliseconds

const char applicationServerUrl[] = "home-auto.eu";
const unsigned int applicationServerPort = 8080; // to unsigned anevazei poly thn xrhsh tis flash, gt?
const char mqttServerUrl[] = "home-auto.eu";
const unsigned int mqttServerPort = 1883;

const unsigned int localUdpPort = 8888;  // local port to listen for UDP packets

const PROGMEM char deviceStatsUpdateUri[] = "/api/v1/devices/DEV_UID/stats_update";
const PROGMEM char deviceAttributesListUri[] = "/api/v1/devices/DEV_UID/attributes_list";
const PROGMEM char deviceAttributesUpdateUri[] = "/api/v1/devices/DEV_UID/attributes_status_update";

// system variables
const byte boilerRelayPin = 7;
const byte tempSensorPin1 = 2;

void initDeviceAttributes(EthernetClient &ethClient, deviceAttribute stateOfAttributes[]);

#endif
