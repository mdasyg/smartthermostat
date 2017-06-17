#include <Arduino.h>

#include "proccess_callbacks.h"

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

const char DEVICE_SERIAL_NUMBER[] = { "555769752436185847" };
const char DEVICE_FIRMWARE_VERSION[] = { "0.0.1" };
const char DEVICE_FRIENDLY_NAME[] = { "home-auto-dev534" };

const char NUMBER_OF_ATTRIBUTES = 2;

const char MQTT_USERNAME[] = { "asdf" };
const char MQTT_PASSWORD[] = { "foobar" };

const byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };

const char applicationServerUrl[] = "home-auto.eu";
const int applicationServerPort = 1024;
const char mqttServerUrl[] = "home-auto.eu";
const int mqttServerPort = 1883;

int init_device_attributes(device_attribute states[]);

#endif
