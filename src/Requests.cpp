#include "DeviceConfigs.h"
#include "Requests.h"

// char httpRequestBuffer[280];
String httpRequestStr;

int result;

void coonectToApplicationServer(EthernetClient &ethClient) {
  Serial.println("Trying to connect to application server...");
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
    Serial.println("Connected to application server");
  }
}

void sendPostRequest(EthernetClient &ethClient, const char url[], const String &postRequestData) {
// SET POST REQUEST
  httpRequestStr = "POST ";
  httpRequestStr += url;
  httpRequestStr += " HTTP/1.1\r\n";
  Serial.print(httpRequestStr);
  ethClient.print(httpRequestStr);
  // set HOST contents
  httpRequestStr = "HOST: ";
  httpRequestStr += applicationServerUrl;
  if (applicationServerPort != 80) {
    httpRequestStr += ":";
    httpRequestStr += applicationServerPort;
  }
  httpRequestStr += "\r\n";
  Serial.print(httpRequestStr);
  ethClient.print(httpRequestStr);
  // set content length
  httpRequestStr = "Content-length: ";
  httpRequestStr += postRequestData.length();
  httpRequestStr += "\r\n";
  Serial.print(httpRequestStr);
  ethClient.print(httpRequestStr);
  // print request data header
  Serial.print("Content-type: application/x-www-form-urlencoded\r\n\r\n");
  ethClient.print("Content-type: application/x-www-form-urlencoded\r\n\r\n");
  // print post data
  Serial.println(postRequestData);
  ethClient.print(postRequestData);
}

void prepareDeviceStatusRequestData(String &postRequestData) {
  postRequestData += "uid=";
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += "&";
  postRequestData += "serial_number=";
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += "&";
  postRequestData += "firmware=";
  postRequestData += DEVICE_FIRMWARE_VERSION;
  postRequestData += "&";
  postRequestData += "friendly_name=";
  postRequestData += DEVICE_FRIENDLY_NAME;
  postRequestData += "&";
  postRequestData += "current_ip=";
  postRequestData += "XXX.YYY.ZZZ.WWW";
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
//

//
//

//
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
