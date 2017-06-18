////// TEST CODE ///////////////////////////////////////////////////////////////
// Serial.println(stateOfAttributes[0].id);
// Serial.println(stateOfAttributes[0].name);
//
// Serial.print("Relay pin address: ");
// Serial.println((unsigned int)&stateOfAttributes, HEX);
// Serial.println((unsigned int)&stateOfAttributes[0], HEX);
// Serial.println((unsigned int)&stateOfAttributes[1], HEX);
////// TEST CODE ///////////////////////////////////////////////////////////////


  //   mqttClient.setServer(mqttServerUrl, mqttServerPort);
  //   mqttClient.setCallback(mqttReceiveMsgCallback);
  //
  //   Serial.print(F("Device Name: "));
  //   Serial.println(DEVICE_FRIENDLY_NAME);
  //   Serial.print(F("Device S/N: "));
  //   Serial.println(DEVICE_SERIAL_NUMBER);
  //   Serial.print(F("Device Firmware: "));
  //   Serial.println(DEVICE_FIRMWARE_VERSION);
  //
  //   postRequestData += "device_uid=";
  //   postRequestData += DEVICE_SERIAL_NUMBER;
  //   postRequestData += "&";
  //   postRequestData += "1=";
  //   postRequestData += DEVICE_SERIAL_NUMBER;
  //   postRequestData += "&";
  //   postRequestData += "2=";
  //   postRequestData += DEVICE_FIRMWARE_VERSION;
  //   postRequestData += "&";
  //   postRequestData += "3=";
  //   postRequestData += DEVICE_FRIENDLY_NAME;
  //
  //   Serial.println(F("Trying to get IP from DHCP..."));
  //   if (Ethernet.begin(mac) == 0) {
  //     while (1) {
  //       Serial.println(F("Failed to configure Ethernet using DHCP"));
  //       delay(10000);
  //     }
  //   }
  //   Serial.print("IP: ");
  //   Serial.println(Ethernet.localIP());
  //
  //   digitalWrite(relayPin, LOW);
  //
  //   Serial.println("Trying to connect to application server...");
  //   result = ethClient.connect(applicationServerUrl, applicationServerPort);
  //   if ( result != 1) {
  //     Serial.print("Connection failed with msg: ");
  //     Serial.println(result);
  //     while (1) {
  //       Serial.println("Please reboot your device");
  //       delay(10000);
  //     }
  //   }
  //   if (ethClient.connected() ) {
  //     Serial.println("Connected to application server");
  //   }
  //
  //   postRequestStr += "POST /devices/statusUpdate HTTP/1.1\r\n";
  //   postRequestStr += "HOST: ";
  //   postRequestStr += applicationServerUrl;
  //   if (applicationServerPort != 80) {
  //     postRequestStr += ":";
  //     postRequestStr += applicationServerPort;
  //   }
  //   postRequestStr += "\r\n";
  //   postRequestStr += "Content-length: ";
  //   postRequestStr += postRequestData.length();
  //   postRequestStr += "\r\n";
  //   postRequestStr += "Content-type: application/x-www-form-urlencoded\r\n\r\n";
  //   postRequestStr += postRequestData;
  //
  //   Serial.println(postRequestStr);
  //
  //   postRequestStr.toCharArray(postRequestBuffer, postRequestStr.length()+1);
  //
  //   Serial.println(postRequestStr.length());
  //
  //   Serial.write(postRequestBuffer, postRequestStr.length());
  //   Serial.println();
  //
  //   ethClient.write(postRequestBuffer, postRequestStr.length())
