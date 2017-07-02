#include <Arduino.h>
#include <Ethernet.h>

#include "DataStructures.h"

const char AMPERSAND = '&';

extern bool isEthClientConnectedToServer;

void coonectToApplicationServer(EthernetClient &ethClient);

void sendPostRequest(EthernetClient &ethClient, const char url[], const String &postRequestData);

void prepareDeviceStatusRequestData(String &postRequestData);
void prepareDeviceAtributesStatusUpdateRequestData(String &postRequestData, deviceAttribute states[]);

// void buildDeviceAttributesRequest(String &postRequestData);
// void buildAndSendGetRequest(EthernetClient &ethClient);
// int httpResponseData(EthernetClient &ethClient, char *httpResponseBuffer);
