#include <Arduino.h>
#include <EthernetUdp.h>

#include "DataStructures.h"

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

const char DEVICE_SERIAL_NUMBER[] = { "555769752436185847" };
const char DEVICE_FIRMWARE_VERSION[] = { "0.0.1" };
const char DEVICE_FRIENDLY_NAME[] = { "home-auto-dev534" };

const char NUMBER_OF_ATTRIBUTES = 2;

const char MQTT_USERNAME[] = { "asdf" };
const char MQTT_PASSWORD[] = { "foobar" };

const char applicationServerUrl[] = "home-auto.eu";
const int applicationServerPort = 1026;
const char mqttServerUrl[] = "home-auto.eu";
const int mqttServerPort = 1883;

const char deviceStatusUrl[] = "/api/v1/devices/status";

// system variables
const int boilerRelayPin = 7;
const int tempSensorPin1 = 4;

int initDeviceAttributes(deviceAttribute states[]);

#endif
