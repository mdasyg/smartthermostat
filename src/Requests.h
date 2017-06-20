#include <Arduino.h>
#include <Ethernet.h>

void buildDeviceInfoSendRequest(String &postRequestData);
void buildDeviceAttributesRequest(String &postRequestData);

void buildPostRequest(EthernetClient &ethClient, const String &postRequestData);
void buildAndSendGetRequest(EthernetClient &ethClient);

int httpResponseData(EthernetClient &ethClient, char *httpResponseBuffer);
