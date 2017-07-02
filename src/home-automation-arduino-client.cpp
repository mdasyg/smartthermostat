#include <Arduino.h>
#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <PubSubClient.h>
#include <TimeLib.h>

#include "DataStructures.h"
#include "DeviceConfigs.h"
#include "ProccessCallbacks.h"
#include "Requests.h"
#include "SystemTime.h"

byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };

String postRequestData;
EthernetClient ethClient;
EthernetUDP udpClient;
PubSubClient mqttClient(ethClient);

char httpResponseBuffer[250];
deviceAttribute stateOfAttributes[NUMBER_OF_ATTRIBUTES];

unsigned int localPort = 8888;  // local port to listen for UDP packets

void setup() {

  Serial.begin(115200);

  pinMode(boilerRelayPin, OUTPUT);
  digitalWrite(boilerRelayPin, LOW);

  initDeviceAttributes(stateOfAttributes);

  Serial.print(F("Device Name: "));
  Serial.println(DEVICE_FRIENDLY_NAME);
  Serial.print(F("Device S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("Device Firmware: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

  // Init EthernetClient
  Serial.println(F("Trying to get IP from DHCP..."));
  if (Ethernet.begin(mac) == 0) {
    while (1) {
      Serial.println(F("Failed to configure Ethernet using DHCP."));
      Serial.println(F("Please reboot."));
      delay(10000);
    }
  }
  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());

  udpClient.begin(localPort);
  setSyncProvider(getNtpTime);

  // Init PubSubClient

  // Send device info to application server
  coonectToApplicationServer(ethClient);
  prepareDeviceStatusRequestData(postRequestData);
  sendPostRequest(ethClient, deviceStatusUrl, postRequestData);

}

int respLen=0;

time_t prevDisplay = 0; // when the digital clock was displayed

void loop() {

  if (timeStatus() != timeNotSet) {
    if ((now() - prevDisplay) >= 10) { //update the display only if time has changed
      prevDisplay = now();
      digitalClockDisplay();
    }
  }

  // ask for data from server
  // buildDeviceAttributesRequest(postRequestData);

  // respLen = httpResponseData(ethClient, httpResponseBuffer);
  // Serial.println("OPPP");
  // Serial.println(respLen);
  // if (respLen) {
  //   Serial.write(httpResponseBuffer, respLen);
  // }

  int counter = 0;
  bool printResponse = false;
  while (ethClient.available()) {
    char c = ethClient.read();
    Serial.print(c);
    if(printResponse) {
      respLen++;
    }
    if (c=='\r' || c=='\n') {
      counter++;
    } else {
      counter = 0;
    }
    if (counter == 4) {
      Serial.println("Molis teliwsan ta headers");
      printResponse = true;
      counter = 0;
    }
  }

  // if the server's disconnected, stop the client:
  if (!ethClient.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    ethClient.stop();
    while(true);
  } else {
    // Serial.println("NO");
  }

  // attribute1ProccessCallback(stateOfAttributes[0]);
  // // attribute2ProccessCallback(properties_state[1]);
  //
  // Serial.println("Device Status");
  // for(int i=0; i<NUMBER_OF_ATTRIBUTES; i++) {
  //   Serial.print(stateOfAttributes[i].name);
  //   Serial.print(": Current value = ");
  //   Serial.print(stateOfAttributes[i].currentValue);
  //   Serial.print(", Set value = ");
  //   Serial.print(stateOfAttributes[i].setValue);
  //   Serial.println();
  // }
  //
  // Serial.println();
  //
  // delay(500);

  // Send statistics to app

  Ethernet.maintain();

}
