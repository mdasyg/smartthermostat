#include "DeviceConfigs.h"
#include "Requests.h"

char httpRequestBuffer[250];
String httpRequestStr;

int result;

void buildDeviceInfoSendRequest(String &postRequestData) {
  postRequestData += "device_uid=";
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
  postRequestData += "xxx.xxx.xxx.xxx";
}

void buildDeviceAttributesRequest(String &httpRequestStr) {

}

void sendHttpRequest(EthernetClient &ethClient, String &httpRequestStr) {
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
  httpRequestStr.toCharArray(httpRequestBuffer, httpRequestStr.length()+1);
  ethClient.write(httpRequestBuffer, httpRequestStr.length());
}

void buildPostRequest(EthernetClient &ethClient, const String &postRequestData) {
  httpRequestStr += "POST /api/v1/devices/attributes HTTP/1.1\r\n";
  httpRequestStr += "HOST: ";
  httpRequestStr += applicationServerUrl;
  if (applicationServerPort != 80) {
    httpRequestStr += ":";
    httpRequestStr += applicationServerPort;
  }
  httpRequestStr += "\r\n";
  httpRequestStr += "Content-length: ";
  httpRequestStr += postRequestData.length();
  httpRequestStr += "\r\n";
  httpRequestStr += "Content-type: application/x-www-form-urlencoded\r\n\r\n";
  httpRequestStr += postRequestData;

  Serial.println(httpRequestStr);
  httpRequestStr.toCharArray(httpRequestBuffer, httpRequestStr.length()+1);
  Serial.println(httpRequestStr.length());
  Serial.write(httpRequestBuffer, httpRequestStr.length());
  Serial.println();
  ethClient.write(httpRequestBuffer, httpRequestStr.length());
}

void buildAndSendGetRequest(EthernetClient &ethClient) {
  httpRequestStr += "GET /api/v1/devices/721367462351557606/attributes.json HTTP/1.1\r\n";
  httpRequestStr += "HOST: ";
  httpRequestStr += applicationServerUrl;
  if (applicationServerPort != 80) {
    httpRequestStr += ":";
    httpRequestStr += applicationServerPort;
  }
  httpRequestStr += "\r\n\r\n";

  sendHttpRequest(ethClient, httpRequestStr);

  return;

}

int httpResponseData(EthernetClient &ethClient, char *httpResponseBuffer) {
  int readLength = 0;
  if(ethClient.available()) {
    while (ethClient.available()) {
      Serial.println("ASDF");
      httpRequestBuffer[readLength] = ethClient.read();
      readLength++;
    }
  }
  return readLength;
}
