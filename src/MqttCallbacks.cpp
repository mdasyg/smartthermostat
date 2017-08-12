#include "MqttCallbacks.h"
#include "System.h"

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print(F("MQTT msg on topic ["));
  Serial.print(topic);
  Serial.print(F("], size ["));
  Serial.print(length);
  Serial.print("] msg: ");
  Serial.write(payload, length);
  Serial.println();

updateAppropriateEntityFromJsonResponse(payload);

}

void mqttConnectToBrokerCallback(PubSubClient &mqttClient) {
  // Serial.println(F("Connecting to MQTT broker"));
  if (mqttClient.connect(DEVICE_FRIENDLY_NAME, MQTT_USERNAME, MQTT_PASSWORD)) {
    // Serial.println(F("Connected to MQTT broker"));
    mqttClient.publish("outTopic", DEVICE_FRIENDLY_NAME);
    mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
    // Serial.print(F("Subscribed to ["));
    // Serial.print(DEVICE_SERIAL_NUMBER);
    // Serial.println(F("] topic"));
  } else {
    Serial.print("Failed, rc=");
    Serial.println(mqttClient.state());
  }
}
