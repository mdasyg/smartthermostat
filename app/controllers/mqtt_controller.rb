class MqttController < ApplicationController

  def index
    sub = Mosquitto::Client.new("tasos-test")

    # Spawn a network thread with a main loop
    sub.loop_start

    # On publish callback
    sub.on_publish do |mid|
      p "Published #{mid}"
    end

    # On connect callback
    sub.on_connect {|rc|
      p "Connected with return code #{rc}"
      # publish a test message once connected
      sub.publish(nil, 'topic', 'test message', Mosquitto::AT_MOST_ONCE, true)
    }

    # Connect to MQTT broker
    sub.connect("10.168.10.50", 1883, 10)


    # Allow some time for processing
    sleep(2)

    sub.disconnect

    # Optional, stop the threaded loop - the network thread would be reaped on Ruby exit as well
    sub.loop_stop(true)

  end

end
