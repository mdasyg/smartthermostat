#include <Arduino.h>
#include <Ethernet.h>

#include "DataStructures.h"

const char AMPERSAND = '&';

extern bool isEthClientConnectedToServer;

bool connectToApplicationServer(EthernetClient &ethClient);

bool sendHttpPostRequest(EthernetClient &ethClient, const String &uri, const String &postRequestData);
// bool buildAndSendGetRequest(EthernetClient &ethClient);
int httpResponseReader(EthernetClient &ethClient);

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const String &uri);
void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const String &uri, deviceAttribute states[]);
