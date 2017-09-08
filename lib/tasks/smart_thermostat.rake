namespace :smart_thermostat do

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
          device_attribute_id         = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:SET_TEMPERATURE][:ID]).source_device_attribute_id
          set_temperature             = DeviceAttribute.find(device_attribute_id).set_value
          sample                      = SmartThermostatHistory.new
          sample.device_uid           = smart_thermostat_device.uid
          sample.sample_datetime      = Time.now.change(sec: 0)
          sample.energy_mode          = SmartThermostat::ENERGY_MODE[:HEATING][:ID]
          sample.energy_source_status = working_state
          sample.outside_temperature  = outside_temperature
          sample.inside_temperature   = inside_temperature
          sample.set_temperature      = set_temperature
          sample.save
        end
      end
    end
  end

  

end
