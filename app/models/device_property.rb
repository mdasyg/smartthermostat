class DeviceProperty < ApplicationRecord

  validates :name,  presence: true

	belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device_properties
	belongs_to :value_type, inverse_of: :device_properties
	has_many :actions, inverse_of: :device_property

end
