#include <Arduino.h>
#include <Ethernet.h>

#include "DataStructures.h"

const char AMPERSAND = '&';

extern bool isEthClientConnectedToServer;

bool connectToApplicationServer(EthernetClient &ethClient);

void sendHttpPostRequest(EthernetClient &ethClient, const char uri[], const String &postRequestData);
void sendHttpGetRequest(EthernetClient &ethClient, const char uri[], const char* queryStringData);
int httpResponseReader(EthernetClient &ethClient);

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const char uri[]);
void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const char uri[], deviceAttribute stateOfAttributes[]);
