#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "System.h"
#include "Requests.h"

void initDeviceAttributes(EthernetClient &ethClient, deviceAttribute stateOfAttributes[]) {
  String flashReadBufferStr;

  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);

  // attribute 1 init
  stateOfAttributes[0].id = 2;
  // attribute 2 init
  stateOfAttributes[1].id = 3;
  // attribute 3 init
  stateOfAttributes[2].id = 4;

  // Request devices attributes list update and wait the reponse on MQTT
  readFromFlash(deviceAttributesListUri, flashReadBufferStr);
  flashReadBufferStr.replace("DEV_UID", DEVICE_SERIAL_NUMBER);
  sendHttpGetRequest(ethClient, flashReadBufferStr);
}
