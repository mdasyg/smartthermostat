#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

// Update these with values suitable for your network.
byte mac[]    = {  0xDE, 0xED, 0xBA, 0xFE, 0xFE, 0xED };
IPAddress ip(10, 168, 10, 100);
IPAddress server(10, 168, 10, 50);

EthernetClient ethClient;
PubSubClient mqttClient(ethClient);

int relayPin = 7;
long millisecs = 0;

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived on [");
  Serial.print(topic);
  Serial.print("] with payload size [");
  Serial.print(length);
  Serial.print("]");

  //  Serial.write(payload, length);
  Serial.println();

  //  Serial.println((int)payload[1]);

  //  Serial.println((int)payload[2]);

  //  Serial.println();

  for (int i = 0; i < length + 10; i++) {
    Serial.println((int)payload[i]);
  }

  Serial.println();

  if ((int)payload[0] == 97) {
    digitalWrite(relayPin, HIGH);
  } else if ((int)payload[0] == 107) {
    digitalWrite(relayPin, LOW);
  }


  mqttClient.publish("outTopic", "XAXAXAXA");

}

void reconnect() {
  // Loop until we're reconnected
  millisecs = millis();
  while (!mqttClient.connected()) {
    Serial.print("Attempting MQTT connection... ");
    // Attempt to connect
    if (mqttClient.connect("arduinoClient")) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      mqttClient.publish("outTopic", "hello world");
      // ... and resubscribe
      mqttClient.subscribe("inTopic");
      Serial.println("Subscribed to [inTopic]");
    } else {
      Serial.print("failed, rc=");
      Serial.println(mqttClient.state());
      //      Serial.println(" try again in 1 seconds");/
      // Wait 5 seconds before retrying
      //      delay(500);
      if (millisecs - millis() > 1000) {
        Serial.println("Another sec passed");
      }
    }
  }
}

void setup() {
  Serial.begin(57600);

  pinMode(relayPin, OUTPUT);

  mqttClient.setServer(server, 1883);
  mqttClient.setCallback(callback);

  Ethernet.begin(mac, ip);

  Serial.print("IP: ");
  Serial.println(Ethernet.localIP());

}

void loop() {
  if (!mqttClient.connected()) {
    reconnect();
  }
  mqttClient.loop();
}
