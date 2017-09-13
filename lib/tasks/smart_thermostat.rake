namespace :smart_thermostat do

  desc 'Check whihch devices are offline for a certain amount of time and send notification'
  task(:send_notification_offline_devices => [:environment]) do |t, args|
    offline_period = Rails.application.secrets.configs[:send_email_notification_after_device_offine_period_in_minutes]
    puts offline_period

    current_time = Time.current

    puts current_time
    minimum_offline_time = current_time.ago(offline_period.minutes)


    offline_devices_to_send_notification_for = Device.where(['last_contact_at <= :minimum_offline_time', { minimum_offline_time: minimum_offline_time }]).find_each

    puts offline_devices_to_send_notification_for.inspect

    UserMailer.notify_user_for_offline_devices(User.first).deliver_now


  end

  desc 'Take sample from device attributes for smart thermostat history and training'
  task(:history_sample => [:environment]) do |t, args|
    smart_thermostat_devices = Device.select(:uid).where(type_c_id: Device::TYPES[:SMART_THERMOSTAT][:ID])
    if smart_thermostat_devices.any?
      smart_thermostat_devices.each do |smart_thermostat_device|
        smart_thermostat_attributes_associations = SmartThermostat.where(smart_device_uid: smart_thermostat_device.uid)
        if smart_thermostat_attributes_associations.any?
          # Find working status
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:WORKING_STATUS][:ID]).source_device_attribute_id
          working_state       = DeviceAttribute.find(device_attribute_id).current_value.to_i
          # Find outside temperature
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:OUTSIDE_TEMPERATURE][:ID]).source_device_attribute_id
          outside_temperature = DeviceAttribute.find(device_attribute_id).current_value.round
          # Find inside temperature
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:INSIDE_TEMPERATURE][:ID]).source_device_attribute_id
          inside_temperature  = DeviceAttribute.find(device_attribute_id).current_value
          # Find set temperature
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:SET_TEMPERATURE][:ID]).source_device_attribute_id
          set_temperature     = DeviceAttribute.find(device_attribute_id).set_value
          # Time now
          sample_datetime = Time.current.change(sec: 0)

          # Prepare the sample
          sample                      = SmartThermostatHistorySample.new
          sample.device_uid           = smart_thermostat_device.uid
          sample.sample_date          = sample_datetime.strftime('%Y-%m-%d')
          sample.sample_time          = sample_datetime.strftime('%H:%M:%S')
          sample.energy_mode          = SmartThermostat::ENERGY_MODE[:HEATING][:ID]
          sample.energy_source_status = working_state
          sample.outside_temperature  = outside_temperature
          sample.inside_temperature   = inside_temperature
          sample.set_temperature      = set_temperature
          sample.save
        else
          puts 'Smart thermostat associations missing'
        end
      end
    else
      puts 'No Smart Thermostat'
    end
  end

  # desc 'Update training dataset'
  # task(:training_dataset => [:environment]) do |t, args|
  #   smart_thermostat_devices = Device.select(:uid).where(type_c_id: Device::TYPES[:SMART_THERMOSTAT][:ID])
  #   if smart_thermostat_devices.any?
  #     smart_thermostat_devices.each do |smart_thermostat_device|
  #       # init help vars
  #       samples_to_check = (24*60)/5
  #       sample_time      = Time.current.change(hour: 0, min: 0, sec: 0)
  #
  #       # Loop through the day
  #       (1..samples_to_check).each do |i|
  #         puts sample_time.strftime('%H:%M:%S')
  #         smart_thermostat_sammples = SmartThermostatHistorySample.select(:sample_time, :outside_temperature)
  #                                         .where(['device_uid = :device_uid AND sample_time = :sample_time', { device_uid: smart_thermostat_device.uid, sample_time: sample_time.strftime('%H:%M:%S') }])
  #                                         .group(:outside_temperature)
  #                                         .average(:inside_temperature)
  #
  #         # puts smart_thermostat_sammples
  #
  #         smart_thermostat_sammples.each do |outside_temperature, inside_temperature_avg|
  #           puts outside_temperature, inside_temperature_avg.round(1)
  #
  #         end
  #
  #         sample_time = sample_time.advance(minutes: 5)
  #       end
  #
  #
  #     end
  #   end
  # end

end
