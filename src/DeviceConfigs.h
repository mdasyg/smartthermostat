#include <avr/pgmspace.h>
#include <Arduino.h>
#include <Ethernet.h>
#include <EthernetUdp.h>

#include "DataStructures.h"

#ifndef DEVICE_CONFIGS_H
#define DEVICE_CONFIGS_H

// device information
const char DEVICE_SERIAL_NUMBER[] =  "905725254349731219"; // BE CAREFUL TO UPDATE DEVICE SERIAL NUMBER

// application server information
const char applicationServerUrl[] = "home-auto.eu";
const unsigned int applicationServerPort = 8080; // to unsigned anevazei poly thn xrhsh tis flash, gt?
const char mqttServerUrl[] = "home-auto.eu";
const unsigned int mqttServerPort = 1883;
const unsigned int localUdpPort = 8888;  // local port to listen for UDP packets
const PROGMEM char apiBaseUrl[] = "/api/v1/devices";
const PROGMEM char deviceDataRequestUri[] = "/get_info?";
const PROGMEM char deviceStatsUpdateUri[] = "/stats_update";
const PROGMEM char deviceAttributesUpdateUri[] = "/attributes_status_update";

#endif
