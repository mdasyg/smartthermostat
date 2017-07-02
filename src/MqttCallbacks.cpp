#include "MqttCallbacks.h"

uint32_t beginWaitMqttConnection;
int mqttConnected = 1; // 0 not connected, 1 conneected // default 1 in order to display the message and init the variable

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print(F("Message arrived on MQTT topic ["));
  Serial.print(topic);
  Serial.print(F("] with payload size ["));
  Serial.print(length);
  Serial.print("] msg [");
  Serial.write(payload, length);
  Serial.println("]");

  if ((int)payload[0] == 97) {
    digitalWrite(boilerRelayPin, HIGH);
  } else if ((int)payload[0] == 107) {
    digitalWrite(boilerRelayPin, LOW);
  }
}

void mqttConnectToBrokerCallback(PubSubClient &mqttClient) {
  uint32_t lastTryMqttConnection = millis();

  Serial.print(F("Inside reconect: "));
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

void mqttPreserveConnectionToBrokerCallback(PubSubClient &mqttClient) {
  if (!mqttClient.connected()) {
    if (mqttConnected == 1) {
      mqttConnected = 0;
      beginWaitMqttConnection = millis();
      Serial.print(F("Inside main loop, mqtt disconected at: "));
      Serial.print(beginWaitMqttConnection);
      Serial.println(" ms");
    }
    mqttConnectToBrokerCallback(mqttClient);
  } else {
    if (mqttConnected == 0) {
      mqttConnected = 1;
      Serial.print(F("Time passed in order to get MQTT connection: "));
      Serial.print(millis() - beginWaitMqttConnection);
      Serial.println(" ms");
    }
  }
}
