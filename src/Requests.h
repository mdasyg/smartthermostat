#include <Arduino.h>
#include <Ethernet.h>

#include "DataStructures.h"

const char HTTP_VERSION[] = " HTTP/1.1\r\n";
const char AMPERSAND[] = "&";
const byte HTTP_REQUEST_BUFFER_SIZE = 100;

extern bool isEthClientConnectedToServer;

bool connectToApplicationServer(EthernetClient &ethClient);

void prepareHttpHeader(char buf[], const char data[]);
void setHttpHost(EthernetClient &ethClient);
bool sendHttpPostRequest(EthernetClient &ethClient, const char uri[], const char postRequestData[]);
bool sendHttpGetRequest(EthernetClient &ethClient, const char uri[], const char* queryStringData);
int httpResponseReader(EthernetClient &ethClient);

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const char uri[]);
void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const char uri[], deviceAttribute stateOfAttributes[]);
