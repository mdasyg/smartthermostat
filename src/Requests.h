#include <Arduino.h>
#include <Ethernet.h>

#include "DataStructures.h"

const char AMPERSAND = '&';

extern bool isEthClientConnectedToServer;

bool connectToApplicationServer(EthernetClient &ethClient);

void sendHttpPostRequest(EthernetClient &ethClient, const String &uri, const String &postRequestData);
void sendHttpGetRequest(EthernetClient &ethClient, const String &uri, const char* queryStringData);
int httpResponseReader(EthernetClient &ethClient);

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const String &uri);
void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const String &uri, deviceAttribute stateOfAttributes[]);
