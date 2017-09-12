#include <ArduinoJson.h>

#include <MemoryFree.h>

#include "DeviceConfigs.h"
#include "Requests.h"
#include "System.h"

bool connectToApplicationServer(EthernetClient &ethClient) {
  ethClient.stop();
  ethClient.connect(applicationServerUrl, applicationServerPort);
  if (ethClient.connected()) {
    isEthClientConnectedToServer = true;
  } else {
    // Serial.println(F("Connection to the app srv failed: "));
    return false;
  }
  return true;
}

void prepareHttpRequestBuffer(char buf[], const char data[]) {
  if (strlen(buf)+strlen(data) < HTTP_REQUEST_BUFFER_SIZE){
    strncpy(&buf[strlen(buf)], data, strlen(data)+1);
    return;
  } else {
    Serial.println(F("HTTP buffer size limit reached, abort"));
    while(1);
  }
}

void setHttpHost(EthernetClient &ethClient) {
  char httpRequestBuffer[HTTP_REQUEST_BUFFER_SIZE];
  char tempBuf[6];
  httpRequestBuffer[0] = 0;
  prepareHttpRequestBuffer(httpRequestBuffer, "HOST: ");
  prepareHttpRequestBuffer(httpRequestBuffer, applicationServerUrl);
  if (applicationServerPort != 80) {
    prepareHttpRequestBuffer(httpRequestBuffer, ":");
    prepareHttpRequestBuffer(httpRequestBuffer, itoa(applicationServerPort, tempBuf, 10));
  }
  prepareHttpRequestBuffer(httpRequestBuffer, "\r\n");
  ethClient.print(httpRequestBuffer);
  return;
}

bool sendHttpGetRequest(EthernetClient &ethClient, const char uri[], const char queryStringData[]) {
  if(!connectToApplicationServer(ethClient)) {
    // Serial.println(F("Abort get request send"));
    return false;
  }

  char httpRequestBuffer[HTTP_REQUEST_BUFFER_SIZE];

  // SET GET REQUEST
  httpRequestBuffer[0] = 0;
  prepareHttpRequestBuffer(httpRequestBuffer, "GET ");
  prepareHttpRequestBuffer(httpRequestBuffer, uri);
  prepareHttpRequestBuffer(httpRequestBuffer, queryStringData);
  prepareHttpRequestBuffer(httpRequestBuffer, HTTP_VERSION);
  ethClient.print(httpRequestBuffer);
  // set HOST contents
  setHttpHost(ethClient);
  // Connection close
  ethClient.print(F("Connection: close\r\n"));
  // finalize request
  ethClient.print(F("\r\n\r\n"));

  return true;
}

bool sendHttpPostRequest(EthernetClient &ethClient, const char uri[], const char postRequestData[]) {
  if(!connectToApplicationServer(ethClient)) {
    // Serial.println(F("Abort post request send"));
    return false;
  }

  char httpRequestBuffer[HTTP_REQUEST_BUFFER_SIZE];
  char tempBuf[6];

  // SET POST REQUEST
  httpRequestBuffer[0] = 0;
  prepareHttpRequestBuffer(httpRequestBuffer, "POST ");
  prepareHttpRequestBuffer(httpRequestBuffer, uri);
  prepareHttpRequestBuffer(httpRequestBuffer, HTTP_VERSION);
  ethClient.print(httpRequestBuffer);
  // set HOST contents
  setHttpHost(ethClient);
  // set Accept request header
  ethClient.print(F("Accept: application/json\r\n"));
  // set content length
  httpRequestBuffer[0] = 0;
  prepareHttpRequestBuffer(httpRequestBuffer,"Content-length: ");
  prepareHttpRequestBuffer(httpRequestBuffer, itoa(strlen(postRequestData), tempBuf, 10));
  prepareHttpRequestBuffer(httpRequestBuffer, "\r\n");
  ethClient.print(httpRequestBuffer);
  // Connection close
  ethClient.print(F("Connection: close\r\n"));
  // print request data header
  ethClient.print(F("Content-type: application/x-www-form-urlencoded\r\n\r\n"));
  // print post data
  ethClient.print(postRequestData);

  return true;
}

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const char uri[]) {
  IPAddress ipAddress;
  byte i;
  char postRequestData[HTTP_REQUEST_BUFFER_SIZE];
  char tempBuf[6];

  ipAddress = Ethernet.localIP();

  postRequestData[0] = 0;
  prepareHttpRequestBuffer(postRequestData, "sn=");
  prepareHttpRequestBuffer(postRequestData, DEVICE_SERIAL_NUMBER);
  prepareHttpRequestBuffer(postRequestData, AMPERSAND);
  prepareHttpRequestBuffer(postRequestData, "fw=");
  prepareHttpRequestBuffer(postRequestData, DEVICE_FIRMWARE_VERSION);
  prepareHttpRequestBuffer(postRequestData, AMPERSAND);
  prepareHttpRequestBuffer(postRequestData, "ip=");
  for (i=0; i<4; i++) {
    prepareHttpRequestBuffer(postRequestData,itoa(ipAddress[i], tempBuf, 10));
    if (i !=3) {
      prepareHttpRequestBuffer(postRequestData,".");
    }
  }

  if(!sendHttpPostRequest(ethClient, uri, postRequestData)) {
    return false;
  }

}

void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const char uri[], deviceAttribute stateOfAttributes[]) {
  byte i;
  int retValue;
  char postRequestData[HTTP_REQUEST_BUFFER_SIZE];
  char tempBuf[6];

  for(i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
    postRequestData[0] = 0;
    prepareHttpRequestBuffer(postRequestData, "da[");
    prepareHttpRequestBuffer(postRequestData, itoa(i, tempBuf, 10));
    prepareHttpRequestBuffer(postRequestData, "][id]=");
    prepareHttpRequestBuffer(postRequestData, itoa(stateOfAttributes[i].id, tempBuf, 10));
    prepareHttpRequestBuffer(postRequestData, AMPERSAND);
    prepareHttpRequestBuffer(postRequestData, "da[");
    prepareHttpRequestBuffer(postRequestData, itoa(i, tempBuf, 10));
    prepareHttpRequestBuffer(postRequestData, "][cur]=");
    prepareHttpRequestBuffer(postRequestData, dtostrf(stateOfAttributes[i].currentValue, 6, 2, tempBuf));
    prepareHttpRequestBuffer(postRequestData, AMPERSAND);
    prepareHttpRequestBuffer(postRequestData, "da[");
    prepareHttpRequestBuffer(postRequestData, itoa(i, tempBuf, 10));
    prepareHttpRequestBuffer(postRequestData, "][set]=");
    prepareHttpRequestBuffer(postRequestData, dtostrf(stateOfAttributes[i].setValue, 6, 2, tempBuf));

    if(!sendHttpPostRequest(ethClient, uri, postRequestData)) {
      break;
    }

    do {
      retValue = httpResponseReader(ethClient);
      if (retValue == -1) {
        break;
      }
    } while(retValue != 0);
  }

  return;

}

// char size[10];
int httpResponseReader(EthernetClient &ethClient) {
  if (ethClient.available()) {

    // while(ethClient.available()) {
    //   char c = ethClient.read();
    //   Serial.print(c);
    // }
    // Serial.println();

    bool ok;

    // // first read Content-length
    // char contentLengthHeaders[] = "Content-Length: ";
    // ok = ethClient.find(contentLengthHeaders);
    // char size[6];
    // ethClient.readBytesUntil('\r', size, 6);
    // unsigned int sizeInt = (int) strtol(size, (char **)NULL, 10);
    // Serial.println(sizeInt);
    // if (sizeInt > FLASH_READ_BUFFER_MAX_SIZE) {
    //   return -1;
    // }

    // HTTP headers end with an empty line
    char endOfHeaders[] = "\r\n\r\n";
    ok = ethClient.find(endOfHeaders);
    if (!ok) {
      Serial.println(F("No response or invalid http response"));
      return -1;
    }

    StaticJsonBuffer<100> jsonBuffer;

    JsonObject& root = jsonBuffer.parseObject(ethClient);

    if (!root.success()) {
      Serial.println(F("parseObject() failed"));
      return -1;
    }

    if(root.containsKey("res")) {
      const char* result = root["res"];
      if (strcmp(result, "ok") != 0) {
        Serial.println(F("Result: ERROR"));
      }
    }

    if(root.containsKey("msg")) {
      const char* msg = root["msg"];
      Serial.println(msg);
    }

  } else {
    return -1;
  }

  return 0;

}
