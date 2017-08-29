#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "System.h"
#include "Requests.h"

void initDeviceAttributes(EthernetClient &ethClient, deviceAttribute stateOfAttributes[]) {
  String flashReadBufferStr;

  stateOfAttributes[STATE_ATTRIBUTE_INDEX].setValue = 0;
  stateOfAttributes[STATE_ATTRIBUTE_INDEX].currentValue = 0;

  // Request devices attributes list update and wait the reponse on MQTT
  readFromFlash(deviceDataRequestUri, flashReadBufferStr);
  flashReadBufferStr.replace("DEV_UID", DEVICE_SERIAL_NUMBER);
  sendHttpGetRequest(ethClient, flashReadBufferStr, "all");
}
