#include <Arduino.h>
#include <PubSubClient.h>

#include "DeviceConfigs.h"

#ifndef MQTT_CALLBACKS_H
#define MQTT_CALLBACKS_H

void mqttConnectToBrokerCallback(PubSubClient &mqttClient);
void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length);

#endif
