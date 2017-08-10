#include <ArduinoJson.h>

#include "DeviceConfigs.h"
#include "Requests.h"
#include "System.h"

bool connectToApplicationServer(EthernetClient &ethClient) {
  int result;
  ethClient.stop();

  // digitalClockDisplay(true); Serial.println(F("Connecting to app server"));

  result = ethClient.connect(applicationServerUrl, applicationServerPort);
  if(result != 1) {
    digitalClockDisplay(true);
    Serial.print(F("Connection failed: "));
    Serial.print(result);
    Serial.println(F(". Retry later"));
  }

  if (ethClient.connected()) {
    isEthClientConnectedToServer = true;
    // digitalClockDisplay(true); Serial.println(F("Connected to app server"));
  } else {
    digitalClockDisplay(true); Serial.println(F("Connect fail to app server"));
    return false;
  }
  return true;
}

bool sendHttpPostRequest(EthernetClient &ethClient, const String &uri, const String &postRequestData) {
  if(!connectToApplicationServer(ethClient)) {
    digitalClockDisplay(true); Serial.println(F("Abort post request send"));
    return false;
  }
  String httpRequestStr;
  // digitalClockDisplay(true); Serial.println(F("Start post request"));

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

  // digitalClockDisplay(true); Serial.println(F("Post request send"));

  return true;
}

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const String &uri) {
  String postRequestData;
  IPAddress ipAddress;
  byte i;

  ipAddress = Ethernet.localIP();

  // digitalClockDisplay(true); Serial.println(F("Preparing device status request data"));
  postRequestData = F("sn=");
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
    postRequestData += ipAddress[i];
    if (i !=3) {
      postRequestData += '.';
    }
  }
  // digitalClockDisplay(true); Serial.println(F("Device status request data ready"));

  sendHttpPostRequest(ethClient, uri, postRequestData);

}

void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const String &uri, deviceAttribute stateOfAttributes[]) {
  String postRequestData;
  byte i;

  // digitalClockDisplay(true); Serial.println(F("Device attributes status update"));

  for(i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
    postRequestData = "";
    postRequestData += F("dev_attr[");
    postRequestData += i;
    postRequestData += F("][id]=");
    postRequestData += stateOfAttributes[i].id;
    postRequestData += AMPERSAND;
    postRequestData += F("dev_attr[");
    postRequestData += i;
    postRequestData += F("][curVal]=");
    postRequestData += stateOfAttributes[i].currentValue;

    sendHttpPostRequest(ethClient, uri, postRequestData);
  }
  // digitalClockDisplay(true); Serial.println(F("Device attributes status update sent"));

  return;

}

// bool buildAndSendGetRequest(EthernetClient &ethClient) {
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

int httpResponseReader(EthernetClient &ethClient) {
  if (ethClient.available()) {
    ethClient.setTimeout(10000);

    // HTTP headers end with an empty line
    char endOfHeaders[] = "\r\n\r\n";
    bool ok = ethClient.find(endOfHeaders);
    if (ok) {
      Serial.println(F("Valid https response. Headers skipped successfully"));
    } else {
      Serial.println(F("No response or invalid response"));
    }

    StaticJsonBuffer<100> jsonBuffer;

    // Test
    JsonObject& root = jsonBuffer.parseObject(ethClient);
    Serial.print(F("jsonBuffer size: ")); Serial.println(jsonBuffer.size());
    Serial.print(F("parsed json size: ")); Serial.println(root.size());

    if (!root.success()) {
      Serial.println(F("parseObject() failed"));
      return -1;
    } else {
      Serial.println(F("PARSE OK"));
    }

    if(root.containsKey("result")) {
      const char* result = root["result"];
      Serial.print(F("Result: ")); Serial.println(result);
    }

    if(root.containsKey("messages")) {
      const char* msgs = root["messages"];
      Serial.print(F("messages: ")); Serial.println(msgs);
    }

    Serial.println();

  }

  return 0;

}
