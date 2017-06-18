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

  //
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
