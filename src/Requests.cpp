#include "DeviceConfigs.h"
#include "Requests.h"
#include "System.h"

bool connectToApplicationServer(EthernetClient &ethClient) {
  int result;
  ethClient.stop();
  digitalClockDisplay(true);
  Serial.println(F("Trying to connect to the application server..."));
  result = ethClient.connect(applicationServerUrl, applicationServerPort);
  if(result != 1) {
    digitalClockDisplay(true);
    Serial.print(F("Connection failed with msg: "));
    Serial.print(result);
    Serial.println(F(". Will retry again later..."));
  }

  if (ethClient.connected()) {
    isEthClientConnectedToServer = true;
    digitalClockDisplay(true);
    Serial.println(F("Connected to the application server"));
  } else {
    digitalClockDisplay(true);
    Serial.println(F("Connection to the application server failed"));
    return false;
  }
  return true;
}

bool sendPostRequest(EthernetClient &ethClient, const char url[], const String &postRequestData) {
  if(!connectToApplicationServer(ethClient)) {
    digitalClockDisplay(true);
    Serial.println(F("Abort request send."));
    return false;
  }
  String httpRequestStr;
  digitalClockDisplay(true);
  Serial.println(F("Begin sending post request..."));
  // SET POST REQUEST
  httpRequestStr = F("POST ");
  httpRequestStr += url;
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

  Serial.print(F("Post data length: "));
  Serial.println(postRequestData.length());

  digitalClockDisplay(true);
  Serial.println(F("Post request send"));
}

void prepareDeviceStatusRequestData(String &postRequestData) {
  digitalClockDisplay(true);
  Serial.println(F("Begin preparing device status request data..."));
  postRequestData = "";
  postRequestData += F("dev_uid=");
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += AMPERSAND;
  postRequestData += F("serial_number=");
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += AMPERSAND;
  postRequestData += F("firmware=");
  postRequestData += DEVICE_FIRMWARE_VERSION;
  postRequestData += AMPERSAND;
  postRequestData += F("friendly_name=");
  postRequestData += DEVICE_FRIENDLY_NAME;
  postRequestData += AMPERSAND;
  postRequestData += F("current_ip=");
  postRequestData += "XXX.YYY.ZZZ.WWW";
  digitalClockDisplay(true);
  Serial.println(F("Device status request data ready"));
}

void prepareDeviceAtributesStatusUpdateRequestData(String &postRequestData, deviceAttribute states[]) {
  digitalClockDisplay(true);
  Serial.println(F("Begin preparing device attributes status update request..."));
  int i;
  postRequestData = "";
  // postRequestData += F("dev_uid=");
  // postRequestData += DEVICE_SERIAL_NUMBER;
  // postRequestData += AMPERSAND;
  for(i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
    if (i>0) {
      postRequestData += AMPERSAND;
    }
    postRequestData += "dev_attr[";
    postRequestData += i;
    postRequestData += "][id]=";
    postRequestData += states[i].id;
    postRequestData += AMPERSAND;
    postRequestData += "dev_attr[";
    postRequestData += i;
    postRequestData += "][curVal]=";
    postRequestData += states[i].currentValue;
  }

  digitalClockDisplay(true);
  Serial.println(F("Device attributes status update data ready"));

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
//
//   sendHttpRequest(ethClient, httpRequestStr);
//
//   return;
//
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
