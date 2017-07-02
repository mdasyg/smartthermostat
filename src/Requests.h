#include <Arduino.h>
#include <Ethernet.h>

void coonectToApplicationServer(EthernetClient &ethClient);

void sendPostRequest(EthernetClient &ethClient, const char url[], const String &postRequestData);

void prepareDeviceStatusRequestData(String &postRequestData);

// void buildDeviceAttributesRequest(String &postRequestData);
// void buildAndSendGetRequest(EthernetClient &ethClient);
// int httpResponseData(EthernetClient &ethClient, char *httpResponseBuffer);
