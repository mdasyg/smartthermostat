#include <dht.h>

#include "DataStructures.h"

#ifndef PROCCES_CALLBACKS_H
#define PROCCES_CALLBACKS_H

int thermostatProccessCallback(deviceAttribute attributesStates[], dht &dht22, uint32_t &lastDHT22QueryTimestamp);

#endif
