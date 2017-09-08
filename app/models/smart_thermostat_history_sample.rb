class SmartThermostatHistorySample < ApplicationRecord

  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :smart_thermostat_history_samples

end
