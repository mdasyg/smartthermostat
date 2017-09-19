class SmartThermostat < ApplicationRecord

  SMART_DEVICE_ATTRIBUTE_TYPES = {
      OUTSIDE_TEMPERATURE: { ID: 1, LABEL: 'Outside Temperature' },
      INSIDE_TEMPERATURE:  { ID: 2, LABEL: 'Inside Temperature' },
      SET_TEMPERATURE:     { ID: 3, LABEL: 'Set Temperature' },
      WORKING_STATUS:      { ID: 4, LABEL: 'Working Status' },
  }

  belongs_to :smart_device, class_name: 'Device', foreign_key: :smart_device_uid, primary_key: :uid, inverse_of: :smart_thermostat_smart_devices
  belongs_to :source_device, class_name: 'Device', foreign_key: :source_device_uid, primary_key: :uid, inverse_of: :smart_thermostat_source_devices
  belongs_to :device_attribute, foreign_key: :source_device_attribute_id, inverse_of: :smart_thermostats

end