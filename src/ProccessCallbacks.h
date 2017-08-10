#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

#include "DataStructures.h"

#ifndef PROCCES_CALLBACKS_H
#define PROCCES_CALLBACKS_H

int thermostatProccessCallback(deviceAttribute attributesStates[], DHT_Unified &dht22, uint32_t &lastDHT22QueryTimestamp, uint32_t minDelayBeforeNextDHT22Query_ms);

#endif
