#include "MqttCallbacks.h"
#include "System.h"

void mqttConnectToBrokerCallback(PubSubClient &mqttClient) {
  if (mqttClient.connect(DEVICE_SERIAL_NUMBER, MQTT_USERNAME, MQTT_PASSWORD)) {
    mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
  } else {
    Serial.println(F("Connection to MQTT broker failed"));
    while(true) {}
  }
}

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  // Serial.print(F("MQTT msg: "));
  // Serial.write(payload, length);
  // Serial.println();
  updateAppropriateEntityFromJsonResponse(payload);
}
