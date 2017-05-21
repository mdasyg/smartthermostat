#include <Arduino.h>

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include "device_configs.h"

byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };

char applicationServerUrl[] = "home-auto.eu";
int applicationServerPort = 1024;
char mqttServerUrl[] = "home-auto.eu";
int mqttServerPort = 1883;
String postRequestStr;
String postRequestData;
char postRequestBuffer[250];

EthernetClient ethClient;
PubSubClient mqttClient(ethClient);

int relayPin = 7;
int result;

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

  Serial.print("Inside reconect: ");
  Serial.println(millis());

  Serial.println(F("Attempting connection to MQTT server..."));
  if (mqttClient.connect(DEVICE_FRIENDLY_NAME, MQTT_USERNAME, MQTT_PASSWORD)) {
    Serial.println("Connected");
    mqttClient.publish("outTopic", DEVICE_FRIENDLY_NAME);
    mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
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
  digitalWrite(relayPin, HIGH);

  Serial.begin(115200);

  mqttClient.setServer(mqttServerUrl, mqttServerPort);
  mqttClient.setCallback(mqttReceiveMsgCallback);

  Serial.print(F("Device Name: "));
  Serial.println(DEVICE_FRIENDLY_NAME);
  Serial.print(F("Device S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);
  Serial.print(F("Device Firmware: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

  postRequestData += "device_uid=";
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += "&";
  postRequestData += "1=";
  postRequestData += DEVICE_SERIAL_NUMBER;
  postRequestData += "&";
  postRequestData += "2=";
  postRequestData += DEVICE_FIRMWARE_VERSION;
  postRequestData += "&";
  postRequestData += "3=";
  postRequestData += DEVICE_FRIENDLY_NAME;

  Serial.println(F("Trying to get IP from DHCP..."));
  if (Ethernet.begin(mac) == 0) {
    while (1) {
      Serial.println(F("Failed to configure Ethernet using DHCP"));
      delay(10000);
    }
  }
  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());

  digitalWrite(relayPin, LOW);

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

  postRequestStr += "POST /devices/statusUpdate HTTP/1.1\r\n";
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

uint32_t beginWaitMqttConnection;
int mqttConnected = 1; // 0 not connected, 1 conneected // default 1 in order to display the message and init the variable

void loop() {

  if (!mqttClient.connected()) {
    if (mqttConnected == 1) {
      mqttConnected = 0;
      beginWaitMqttConnection = millis();
      Serial.print(F("Inside main loop, mqtt disconected at: "));
      Serial.print(beginWaitMqttConnection);
      Serial.println(" ms");
    }
    mqttConnectToBrokerCallback();
  } else {
    if (mqttConnected == 0) {
      mqttConnected = 1;
      Serial.print(F("Time passed in order to get MQTT connection: "));
      Serial.print(millis() - beginWaitMqttConnection);
      Serial.println(" ms");
    }
    mqttClient.loop();
  }

}
