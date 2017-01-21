class DeviceProperty < ApplicationRecord
	
	belongs_to :device, primary_key: :uid, inverse_of: :device_properties

	belongs_to :property_type, inverse_of: :device_properties
  belongs_to :value_type, inverse_of: :device_properties

end
