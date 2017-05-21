#include <Arduino.h>

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include "device_configs.h"

// Update these with values suitable for your network.
byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };
IPAddress deviceIp(10, 168, 10, 100); // client address
IPAddress mqttServerIp(10, 168, 10, 50);
char applicationServerUrl[] = "home-auto.eu";
int applicationServerPort = 1024;
byte sendPostDataBuffer[200] = {0};
String postDataToSend;
String postQuery;
char postBuffer[250];
int result;

EthernetClient ethClient;
PubSubClient mqttClient(ethClient);

int relayPin = 7;
long millisecs = 0;

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print(F("Message arrived on MQTT topic ["));
  Serial.print(topic);
  Serial.print(F("] with payload size ["));
  Serial.print(length);
  Serial.print("] msg [");
  Serial.write(payload, length);
  Serial.println("]");

  if ((int)payload[0] == 97) {
    digitalWrite(relayPin, HIGH);
  } else if ((int)payload[0] == 107) {
    digitalWrite(relayPin, LOW);
  }
}

void mqttConnectToBrokerCallback() {

  uint32_t lastTryMqttConnection = millis();
  int reqRes;

  Serial.print("Inside reconect: ");
  Serial.println(millis());

  Serial.println(F("Attempting connection to MQTT server..."));
  if (mqttClient.connect(DEVICE_FRIENDLY_NAME, MQTT_USERNAME, MQTT_PASSWORD)) {
    Serial.println("Connected");
    reqRes = mqttClient.publish("outTopic", DEVICE_FRIENDLY_NAME);
    Serial.print("Publish request result: ");
    Serial.println(reqRes);
    Serial.println(mqttClient.state());
    mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
    Serial.print("Subscribe request result: ");
    Serial.println(reqRes);
    Serial.println(mqttClient.state());
    Serial.print(F("Subscribed to ["));
    Serial.print(DEVICE_SERIAL_NUMBER);
    Serial.println(F("] topic"));
  } else {
    Serial.print("Failed, rc=");
    Serial.println(mqttClient.state());
    if (millis() - lastTryMqttConnection > 1000) {
      Serial.println(F("Another sec passed"));
      lastTryMqttConnection = millis();
    }
  }

}

void setup() {
  pinMode(relayPin, OUTPUT);

  Serial.begin(115200);

  mqttClient.setServer(mqttServerIp, 1883);
  mqttClient.setCallback(mqttReceiveMsgCallback);

  Serial.print(F("Device Name: "));
  Serial.println(DEVICE_FRIENDLY_NAME);
  Serial.print(F("Device S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("Device Firmware: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

  postDataToSend += "device_uid=";
  postDataToSend += DEVICE_SERIAL_NUMBER;
  postDataToSend += "&";
  postDataToSend += "1=";
  postDataToSend += DEVICE_SERIAL_NUMBER;
  postDataToSend += "&";
  postDataToSend += "2=";
  postDataToSend += DEVICE_FIRMWARE_VERSION;
  postDataToSend += "&";
  postDataToSend += "3=";
  postDataToSend += DEVICE_FRIENDLY_NAME;

  Serial.println(F("Trying to get IP from DHCP..."));
  if (Ethernet.begin(mac) == 0) {
    while (1) {
      Serial.println(F("Failed to configure Ethernet using DHCP"));
      delay(10000);
    }
  }
  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());

  digitalWrite(relayPin, HIGH);

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


  postQuery += "POST /devices/statusUpdate HTTP/1.1\r\n";
  postQuery += "HOST: ";
  postQuery += applicationServerUrl;
  if (applicationServerPort != 80) {
    postQuery += ":";
    postQuery += applicationServerPort;
  }
  postQuery += "\r\n";
  postQuery += "Content-length: ";
  postQuery += postDataToSend.length();
  postQuery += "\r\n";
  postQuery += "Content-type: application/x-www-form-urlencoded\r\n\r\n";
  postQuery += postDataToSend;

  Serial.println(postQuery);

  postQuery.toCharArray(postBuffer, postQuery.length()+1);

  Serial.println(postQuery.length());

  Serial.write(postBuffer, postQuery.length());
  Serial.println();

  ethClient.write(postBuffer, postQuery.length());

}

// uint32_t beginWaitMqttConnection;
// int mqttConnected = 1; // 0 not connected, 1 conneected // default 1 in order to display the message and init the variable

void loop() {


  while(1) {
    Serial.println("Please Reboot...");
    delay(10000);
  }

  // if (!mqttClient.connected()) {
  //   if (mqttConnected == 1) {
  //     mqttConnected = 0;
  //     beginWaitMqttConnection = millis();
  //     Serial.print(F("Inside main loop, mqtt disconected: "));
  //     Serial.println(beginWaitMqttConnection);
  //   }
  //   mqttConnectToBrokerCallback();
  // } else {
  //   if (mqttConnected == 0) {
  //     mqttConnected = 1;
  //     Serial.print(F("Time passed in order to get MQTT connection: "));
  //     Serial.print(millis() - beginWaitMqttConnection);
  //     Serial.println(" ms");
  //   }
  //   mqttClient.loop();
  // }

}
