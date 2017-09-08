class Device < ApplicationRecord
  has_secure_token :access_token

  TYPES = {
      SMART_THERMOSTAT: { ID: 1, LABEL: 'Smart Thermostat' },
      WEATHER_STATION:  { ID: 2, LABEL: 'Weather Station' },
  }

  validates :name, :location, presence: true

  before_create do
    n        = 18 # Take this from project settings
    self.uid = rand((10**(n - 1))..(10**n)) # make something to add error if exist something....
  end

  belongs_to :user, inverse_of: :devices
  has_many :device_attributes, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device, autosave: true
  has_many :device_stats, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device
  has_many :schedule_events, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device
  has_many :quick_buttons, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device

  has_many :smart_thermostat_smart_devices, class_name: 'SmartThermostat', foreign_key: :smart_device_uid, primary_key: :uid, inverse_of: :smart_device
  has_many :smart_thermostat_source_devices, class_name: 'SmartThermostat', foreign_key: :source_device_uid, primary_key: :uid, inverse_of: :source_device

end
