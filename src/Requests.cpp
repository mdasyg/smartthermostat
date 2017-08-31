#include <ArduinoJson.h>

#include "DeviceConfigs.h"
#include "Requests.h"
#include "System.h"

bool connectToApplicationServer(EthernetClient &ethClient) {
  ethClient.stop();

  ethClient.connect(applicationServerUrl, applicationServerPort);

  if (ethClient.connected()) {
    isEthClientConnectedToServer = true;
  } else {
    // Serial.print(F("Connection to the app srv failed: "));
    return false;
  }
  return true;
}

void sendHttpGetRequest(EthernetClient &ethClient, const char uri[], const char* queryStringData) {
  if(!connectToApplicationServer(ethClient)) {
    // Serial.println(F("Abort get request send"));
    return;
  }
  String httpRequestStr;

  // SET GET REQUEST
  httpRequestStr = F("GET ");
  httpRequestStr += uri;
  httpRequestStr += queryStringData;
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
  // Connection close
  ethClient.print(F("Connection: close\r\n"));
  // finalize request
  ethClient.print("\r\n\r\n");

  return;
}

void sendHttpPostRequest(EthernetClient &ethClient, const char uri[], const String &postRequestData) {
  if(!connectToApplicationServer(ethClient)) {
    // Serial.println(F("Abort post request send"));
    return;
  }
  String httpRequestStr;

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

  return;
}

void sendDeviceStatsUpdateToApplicationServer(EthernetClient &ethClient, const char uri[]) {
  String postRequestData;
  IPAddress ipAddress;
  byte i;

  ipAddress = Ethernet.localIP();
  postRequestData = F("sn=");
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += AMPERSAND;
  postRequestData += F("fw=");
  postRequestData += DEVICE_FIRMWARE_VERSION;
  postRequestData += AMPERSAND;
  postRequestData += F("ip=");
  for (i=0; i<4; i++) {
    postRequestData += ipAddress[i];
    if (i !=3) {
      postRequestData += '.';
    }
  }

  sendHttpPostRequest(ethClient, uri, postRequestData);

}

void sendDeviceAtributesStatusUpdateToApplicationServer(EthernetClient &ethClient, const char uri[], deviceAttribute stateOfAttributes[]) {
  String postRequestData;
  byte i;
  int retValue;

  for(i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
    postRequestData = "";
    postRequestData += F("da[");
    postRequestData += i;
    postRequestData += F("][id]=");
    postRequestData += stateOfAttributes[i].id;
    postRequestData += AMPERSAND;
    postRequestData += F("da[");
    postRequestData += i;
    postRequestData += F("][cur]=");
    postRequestData += stateOfAttributes[i].currentValue;
    postRequestData += AMPERSAND;
    postRequestData += F("da[");
    postRequestData += i;
    postRequestData += F("][set]=");
    postRequestData += stateOfAttributes[i].setValue;
    sendHttpPostRequest(ethClient, uri, postRequestData);

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
    // some response found. Examine it.
    ethClient.setTimeout(10000);

    bool ok;

    // // first read Content-length
    // char contentLengthHeaders[] = "Content-Length: ";
    // ok = ethClient.find(contentLengthHeaders);
    //
    // ethClient.readBytesUntil('\r', size, 10);
    //
    // Serial.println(sizeof(size));

    // HTTP headers end with an empty line
    char endOfHeaders[] = "\r\n\r\n";
    ok = ethClient.find(endOfHeaders);
    if (!ok) {
      // Serial.println(F("No response or invalid http response"));
      return -1;
    }

    StaticJsonBuffer<100> jsonBuffer;

    JsonObject& root = jsonBuffer.parseObject(ethClient);

    if (!root.success()) {
      // Serial.println(F("parseObject() failed"));
      return -1;
    }

    if(root.containsKey("res")) {
      const char* result = root["res"];
      if (strcmp(result, "ok") != 0) {
        // Serial.println(F("Result: ERROR"));
      }

    }

    if(root.containsKey("msg")) {
      // Serial.println(F("Response contains msg"));
    }

  } else {
    return 1;
  }

  return 0;

}
