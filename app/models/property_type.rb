class PropertyType < ApplicationRecord

	has_many :device_properties, inverse_of: :property_type
	has_many :value_types, inverse_of: :property_type

end
