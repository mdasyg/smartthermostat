#include "MqttCallbacks.h"
#include "System.h"

void mqttConnectToBrokerCallback(PubSubClient &mqttClient) {
  if (mqttClient.connect(DEVICE_SERIAL_NUMBER, MQTT_USERNAME, MQTT_PASSWORD)) {
  } else {
    // Serial.println(F("Connection to MQTT broker failed"));
  }
}

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  // Serial.print(F("MQTT msg: "));
  // Serial.write(payload, length);
  // Serial.println();
  updateAppropriateEntityFromJsonResponse(payload);
}
