#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include "home-automation-arduino-client.h"

// Update these with values suitable for your network.
byte mac[] = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };
IPAddress deviceIp(10, 168, 10, 100); // client address
IPAddress mqttServerIp(10, 168, 10, 50);

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

  mqttClient.publish("outTopic", "XAXAXAXA");

}

void mqttConnectionCallback() {

  uint32_t lastTryMqttConnection = millis();
  int reqRes;

  Serial.print("Inside reconect: ");
  Serial.println(millis());

  Serial.println(F("Attempting connection to MQTT server..."));
  if (mqttClient.connect("arduinoClient")) {
    Serial.println("Connected");
    reqRes = mqttClient.publish("outTopic", "hello world");
    Serial.print("Publish request result: ");
    Serial.println(reqRes);
    Serial.println(mqttClient.state());
    mqttClient.subscribe("inTopic");
    Serial.print("Subscribe request result: ");
    Serial.println(reqRes);
    Serial.println(mqttClient.state());
    Serial.println(F("Subscribed to [inTopic]"));
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

  mqttClient.setServer(mqttServerIp, 1883);
  mqttClient.setCallback(mqttReceiveMsgCallback);

  Serial.begin(57600);

  Serial.print(F("Device S/N: "));
  Serial.println(DEVICE_SERIAL_NUMBER);

  Serial.print(F("Device Firmware: "));
  Serial.println(DEVICE_FIRMWARE_VERSION);

  Serial.println(F("Trying to get IP from DHCP..."));
  if (Ethernet.begin(mac) == 0) {
    while (1) {
      Serial.println(F("Failed to configure Ethernet using DHCP"));
      delay(10000);
    }
  }
  //  Ethernet.begin(mac, deviceIp);
  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());

}

uint32_t beginWaitMqttConnection;
int mqttConnected = 1; // 0 not connected, 1 conneected // default 1 in order to display the message and init the variable

void loop() {

  if (!mqttClient.connected()) {
    if (mqttConnected == 1) {
      mqttConnected = 0;
      beginWaitMqttConnection = millis();
      Serial.print(F("Inside main loop, mqtt disconected: "));
      Serial.println(beginWaitMqttConnection);
    }
    mqttConnectionCallback();
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
