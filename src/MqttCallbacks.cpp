#include "MqttCallbacks.h"
#include "System.h"

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  digitalClockDisplay(true);
  Serial.print(F("Message arrived on MQTT topic ["));
  Serial.print(topic);
  Serial.print(F("] with payload size ["));
  Serial.print(length);
  Serial.print("] msg: ");
  Serial.write(payload, length);
  Serial.println();

  if ((int)payload[0] == 97) {
    digitalWrite(boilerRelayPin, HIGH);
  } else if ((int)payload[0] == 107) {
    digitalWrite(boilerRelayPin, LOW);
  }
}

void mqttConnectToBrokerCallback(PubSubClient &mqttClient) {
  digitalClockDisplay(true);
  Serial.println(F("Attempting connection to MQTT server..."));
  if (mqttClient.connect(DEVICE_FRIENDLY_NAME, MQTT_USERNAME, MQTT_PASSWORD)) {
    digitalClockDisplay(true);
    Serial.println(F("Connected to MQTT broker"));
    mqttClient.publish("outTopic", DEVICE_FRIENDLY_NAME);
    mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
    digitalClockDisplay(true);
    Serial.print(F("Subscribed to ["));
    Serial.print(DEVICE_SERIAL_NUMBER);
    Serial.println(F("] topic"));
  } else {
    digitalClockDisplay(true);
    Serial.print("Failed, rc=");
    Serial.println(mqttClient.state());
  }
}
