class PropertyType < ApplicationRecord

	has_many :device_properties, inverse_of: :property_type

end
