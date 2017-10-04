# Thesis prototype thermostat device

This is a prototype for a smart thermostat, which developed for the purpose of my thesis. It is developed in the Arduino platform.

# Requirements (libraries)

1. PubSubClient by Nick O'Leary ([GitHub](https://github.com/knolleary/pubsubclient))
2. ArduinoJson by Benoit Blanchon ([GitHub](https://github.com/bblanchon/ArduinoJson))
3. Time by Michael Margolis ([GitHub](https://github.com/PaulStoffregen/Time))
4. DHTLib by Rob Tillaart ([GitHub](https://github.com/RobTillaart/Arduino/tree/master/libraries/DHTlib))
5. MemoryFree by maniacbug ([GitHub](https://github.com/maniacbug/MemoryFree))

# Installation

## Arduino IDE

1. You have to manually download from library manager and/or from github the required libraries
2. You can compile and upload to arduino

## Atom/PlatformIO

1. You have to install [atom](https://atom.io/) Text Editor
2. Install PlatformIO package, follow instructions [here](http://platformio.org/get-started/ide?install=atom)
3. After that you can compile and upload the project to the arduino. The dependencies will be downloaded automatically

# Files preparation

1. You must rename or copy the DeviceSecrets.h.example to DeviceSecrets.h and add the appropriate information

# Notes

+ Be carefull when error pages return to the arduino, it restarts
