#include "MqttCallbacks.h"
#include "System.h"

void mqttConnectToBrokerCallback(PubSubClient &mqttClient) {
  if (mqttClient.connect(DEVICE_FRIENDLY_NAME, MQTT_USERNAME, MQTT_PASSWORD)) {
    mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
  } else {
    // Serial.println(F("Connection to MQTT broker failed"));
  }
}

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  updateAppropriateEntityFromJsonResponse(payload);

  // Serial.print(F("MQTT msg: "));
  // Serial.write(payload, length);
  // Serial.println();
}
