#include "DeviceConfigs.h"
#include "Requests.h"

char postRequestBuffer[250];

String postRequestStr;

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

void buildDeviceAttributesRequest(String &postRequestStr) {

}

void sendPostRequest(EthernetClient &ethClient, const String &postRequestData) {
  postRequestStr += "POST /api/v1/devices/attributes HTTP/1.1\r\n";
  postRequestStr += "HOST: ";
  postRequestStr += applicationServerUrl;
  if (applicationServerPort != 80) {
    postRequestStr += ":";
    postRequestStr += applicationServerPort;
  }
  postRequestStr += "\r\n";
  postRequestStr += "Content-length: ";
  postRequestStr += postRequestData.length();
  postRequestStr += "\r\n";
  postRequestStr += "Content-type: application/x-www-form-urlencoded\r\n\r\n";
  postRequestStr += postRequestData;

  Serial.println(postRequestStr);
  postRequestStr.toCharArray(postRequestBuffer, postRequestStr.length()+1);
  Serial.println(postRequestStr.length());
  Serial.write(postRequestBuffer, postRequestStr.length());
  Serial.println();
  ethClient.write(postRequestBuffer, postRequestStr.length());
}

int result;
void sendGetRequest(EthernetClient &ethClient) {

  Serial.println("Try to send get request");

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

  postRequestStr += "GET /api/v1/devices/721367462351557606/attributes.json HTTP/1.1\r\n";
  postRequestStr += "HOST: ";
  postRequestStr += applicationServerUrl;
  if (applicationServerPort != 80) {
    postRequestStr += ":";
    postRequestStr += applicationServerPort;
  }
  postRequestStr += "\r\n";
  postRequestStr += "accept: application/json";
  postRequestStr += "\r\n";

  Serial.println(postRequestStr);
  postRequestStr.toCharArray(postRequestBuffer, postRequestStr.length()+1);
  ethClient.write(postRequestBuffer, postRequestStr.length());

  Serial.println("Send it");

  return;

}
