#include <Arduino.h>
#include <Ethernet.h>

void buildDeviceInfoSendRequest(String &postRequestData);
void buildDeviceAttributesRequest(String &postRequestData);

void sendPostRequest(EthernetClient &ethClient, const String &postRequestData);
void sendGetRequest(EthernetClient &ethClient);
