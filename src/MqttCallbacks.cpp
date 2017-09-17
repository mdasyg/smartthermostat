#include "MqttCallbacks.h"
#include "System.h"

void mqttConnectToBrokerCallback(EthernetClient &ethClientForMqtt, PubSubClient &mqttClient) {
  ethClientForMqtt.stop();
  if (mqttClient.connect(DEVICE_SERIAL_NUMBER)) {
    mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
  } else {
    // Serial.println(F("Connection to MQTT broker failed"));
  }
}

void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
  // Serial.print(F("MQTT msg: ")); Serial.write(payload, length); Serial.println();
  updateAppropriateEntityFromJsonResponse(payload);
}
