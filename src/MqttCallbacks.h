#include <Arduino.h>
#include <PubSubClient.h>

#include "DeviceConfigs.h"

#ifndef MQTT_CALLBACKS_H
#define MQTT_CALLBACKS_H

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length);
void mqttConnectToBrokerCallback(PubSubClient &mqttClient);
void mqttPreserveConnectionToBrokerCallback(PubSubClient &mqttClient);

#endif
