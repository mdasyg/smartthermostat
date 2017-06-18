// void mqttReceiveMsgCallback(char* topic, byte* payload, unsigned int length) {
//   Serial.print(F("Message arrived on MQTT topic ["));
//   Serial.print(topic);
//   Serial.print(F("] with payload size ["));
//   Serial.print(length);
//   Serial.print("] msg [");
//   Serial.write(payload, length);
//   Serial.println("]");
//
//   if ((int)payload[0] == 97) {
//     digitalWrite(relayPin, HIGH);
//   } else if ((int)payload[0] == 107) {
//     digitalWrite(relayPin, LOW);
//   }
// }
//
// void mqttConnectToBrokerCallback() {
//   uint32_t lastTryMqttConnection = millis();
//
//   Serial.print("Inside reconect: ");
//   Serial.println(millis());
//
//   Serial.println(F("Attempting connection to MQTT server..."));
//   if (mqttClient.connect(DEVICE_FRIENDLY_NAME, MQTT_USERNAME, MQTT_PASSWORD)) {
//     Serial.println("Connected");
//     mqttClient.publish("outTopic", DEVICE_FRIENDLY_NAME);
//     mqttClient.subscribe(DEVICE_SERIAL_NUMBER);
//     Serial.print(F("Subscribed to ["));
//     Serial.print(DEVICE_SERIAL_NUMBER);
//     Serial.println(F("] topic"));
//   } else {
//     Serial.print("Failed, rc=");
//     Serial.println(mqttClient.state());
//     if (millis() - lastTryMqttConnection > 1000) {
//       Serial.println(F("Another sec passed"));
//       lastTryMqttConnection = millis();
//     }
//   }
// }

// void preserveConnectionCallback() {

  //   if (!mqttClient.connected()) {
  //     if (mqttConnected == 1) {
  //       mqttConnected = 0;
  //       beginWaitMqttConnection = millis();
  //       Serial.print(F("Inside main loop, mqtt disconected at: "));
  //       Serial.print(beginWaitMqttConnection);
  //       Serial.println(" ms");
  //     }
  //     mqttConnectToBrokerCallback();
  //   } else {
  //     if (mqttConnected == 0) {
  //       mqttConnected = 1;
  //       Serial.print(F("Time passed in order to get MQTT connection: "));
  //       Serial.print(millis() - beginWaitMqttConnection);
  //       Serial.println(" ms");
  //     }
  //     mqttClient.loop();
  //   }

// }
