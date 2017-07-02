#include "DeviceConfigs.h"
#include "Requests.h"

// char httpRequestBuffer[280];
String httpRequestStr;

int result;

void coonectToApplicationServer(EthernetClient &ethClient) {
  Serial.println("Trying to connect to application server...");
  ethClient.stop();
  result = ethClient.connect(applicationServerUrl, applicationServerPort);
  if ( result != 1) {
    Serial.print("Connection failed with msg: ");
    Serial.println(result);
    while (1) {
      Serial.println("Please reboot your device");
      delay(10000);
    }
  }
  if (ethClient.connected() ) {
    isEthClientConnectedToServer = true;
    Serial.println("Connected to application server");
  }
}

void sendPostRequest(EthernetClient &ethClient, const char url[], const String &postRequestData) {
  coonectToApplicationServer(ethClient);
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
}

void prepareDeviceStatusRequestData(String &postRequestData) {
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
}

void prepareDeviceAtributesStatusUpdateRequestData(String &postRequestData, deviceAttribute states[]) {
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
