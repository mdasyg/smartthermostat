#include "DeviceConfigs.h"
#include "Requests.h"
#include "SystemTime.h"

// char httpRequestBuffer[280];
String httpRequestStr;

int result;

void coonectToApplicationServer(EthernetClient &ethClient) {
  digitalClockDisplay(true);
  Serial.println("Trying to connect to application server...");
  ethClient.stop();
  result = ethClient.connect(applicationServerUrl, applicationServerPort);
  if ( result != 1) {
    digitalClockDisplay(true);
    Serial.print("Connection failed with msg: ");
    Serial.println(result);
    while (1) {
      digitalClockDisplay(true);
      Serial.println("Please reboot your device");
      delay(10000);
    }
  }
  if (ethClient.connected() ) {
    isEthClientConnectedToServer = true;
    digitalClockDisplay(true);
    Serial.println("Connected to application server");
  }
}

void sendPostRequest(EthernetClient &ethClient, const char url[], const String &postRequestData) {
  coonectToApplicationServer(ethClient);
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

  digitalClockDisplay(true);
  Serial.println(F("Post request send"));
}

void prepareDeviceStatusRequestData(String &postRequestData) {
  digitalClockDisplay(true);
  Serial.println(F("Begin preparing device status request data..."));
  postRequestData = "";
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
