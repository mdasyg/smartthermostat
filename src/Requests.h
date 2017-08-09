#include <Arduino.h>
#include <Ethernet.h>

#include "DataStructures.h"

const char AMPERSAND = '&';

extern bool isEthClientConnectedToServer;

bool connectToApplicationServer(EthernetClient &ethClient);

bool sendHttpPostRequest(EthernetClient &ethClient, const String &uri, const String &postRequestData);

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const String &uri);
void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const String &uri, deviceAttribute states[]);

// void buildDeviceAttributesRequest(String &postRequestData);
// void buildAndSendGetRequest(EthernetClient &ethClient);
// int httpResponseData(EthernetClient &ethClient, char *httpResponseBuffer);
