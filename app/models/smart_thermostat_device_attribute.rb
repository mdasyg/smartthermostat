class SmartThermostatDeviceAttribute < ApplicationRecord

  TYPES = {
      OUTSIDE_TEMPERATURE: { ID: 1, LABEL: 'Outside Temperature' },
      INSIDE_TEMPERATURE:  { ID: 2, LABEL: 'Inside Temperature' },
      SET_TEMPERATURE:     { ID: 3, LABEL: 'Set Temperature' },
      WORKING_STATUS:      { ID: 4, LABEL: 'Working Status' },
  }

  belongs_to :device_attribute, inverse_of: :smart_thermostat_device_attributes

end