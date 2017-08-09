#include "DeviceConfigs.h"
#include "Requests.h"
#include "System.h"

bool connectToApplicationServer(EthernetClient &ethClient) {
  int result;
  ethClient.stop();
  digitalClockDisplay(true);
  Serial.println(F("Connecting to app server"));
  result = ethClient.connect(applicationServerUrl, applicationServerPort);
  if(result != 1) {
    digitalClockDisplay(true);
    Serial.print(F("Connection failed: "));
    Serial.print(result);
    Serial.println(F(". Retry later"));
  }

  if (ethClient.connected()) {
    isEthClientConnectedToServer = true;
    digitalClockDisplay(true);
    Serial.println(F("Connected to app server"));
  } else {
    digitalClockDisplay(true);
    Serial.println(F("Failed to connect to app server"));
    return false;
  }
  return true;
}

bool sendHttpPostRequest(EthernetClient &ethClient, const String &uri, const String &postRequestData) {
  if(!connectToApplicationServer(ethClient)) {
    digitalClockDisplay(true);
    Serial.println(F("Abort request send"));
    return false;
  }
  String httpRequestStr;
  digitalClockDisplay(true);
  Serial.println(F("Start post request"));

  // SET POST REQUEST
  httpRequestStr = F("POST ");
  httpRequestStr += uri;
  httpRequestStr += F(" HTTP/1.1\r\n");
  ethClient.print(httpRequestStr);
  // set HOST contents
  httpRequestStr = F("HOST: ");
  httpRequestStr += applicationServerUrl;
  if (applicationServerPort != 80) {
    httpRequestStr += ":";
    httpRequestStr += applicationServerPort;
  }
  httpRequestStr += F("\r\n");
  ethClient.print(httpRequestStr);
  // set Accept request header
  ethClient.print(F("Accept: application/json\r\n"));
  // set content length
  httpRequestStr = F("Content-length: ");
  httpRequestStr += postRequestData.length();
  httpRequestStr += F("\r\n");
  ethClient.print(httpRequestStr);
  // Connection close
  ethClient.print(F("Connection: close\r\n"));
  // print request data header
  ethClient.print(F("Content-type: application/x-www-form-urlencoded\r\n\r\n"));
  // print post data
  ethClient.print(postRequestData);

  digitalClockDisplay(true);
  Serial.println(F("Post request send"));

  return true;
}

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const String &uri) {
  String postRequestData;
  IPAddress ipAddress;
  int i;

  ipAddress = Ethernet.localIP();

  digitalClockDisplay(true);
  Serial.println(F("Preparing device status request data"));
  postRequestData = "";
  postRequestData += F("sn=");
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += AMPERSAND;
  postRequestData += F("fw=");
  postRequestData += DEVICE_FIRMWARE_VERSION;
  postRequestData += AMPERSAND;
  postRequestData += F("friendly_name=");
  postRequestData += DEVICE_FRIENDLY_NAME;
  postRequestData += AMPERSAND;
  postRequestData += F("ip=");
  for (i=0; i<4; i++) {
    postRequestData += String(ipAddress[i]);
    if (i !=3) {
      postRequestData += '.';
    }
  }
  digitalClockDisplay(true);
  Serial.println(F("Device status request data ready"));

  sendHttpPostRequest(ethClient, uri, postRequestData);

}

void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const String &uri, deviceAttribute states[]) {
  String postRequestData;

  digitalClockDisplay(true);
  Serial.println(F("Device attributes status update"));

  byte i;
  for(i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
    postRequestData = "";
    postRequestData += F("dev_attr[");
    postRequestData += i;
    postRequestData += F("][id]=");
    postRequestData += states[i].id;
    postRequestData += AMPERSAND;
    postRequestData += F("dev_attr[");
    postRequestData += i;
    postRequestData += F("][curVal]=");
    postRequestData += states[i].currentValue;

    sendHttpPostRequest(ethClient, uri, postRequestData);
  }

  digitalClockDisplay(true);
  Serial.println(F("Device attributes status update sent"));

  return;

}

// void buildAndSendGetRequest(EthernetClient &ethClient) {
//   httpRequestStr += "GET /api/v1/devices/721367462351557606/attributes.json HTTP/1.1\r\n";
//   httpRequestStr += "HOST: ";
//   httpRequestStr += applicationServerUrl;
//   if (applicationServerPort != 80) {
//     httpRequestStr += ":";
//     httpRequestStr += applicationServerPort;
//   }
//   httpRequestStr += "\r\n\r\n";
//   sendHttpRequest(ethClient, httpRequestStr);
//   return;
// }

// void buildDeviceAttributesRequest(String &httpRequestStr) {
//
// }

// int httpResponseData(EthernetClient &ethClient, char *httpResponseBuffer) {
//   int readLength = 0;
//   if(ethClient.available()) {
//     while (ethClient.available()) {
//       Serial.println("ASDF");
//       httpRequestBuffer[readLength] = ethClient.read();
//       readLength++;
//     }
//   }
//   return readLength;
// }
