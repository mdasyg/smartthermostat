class PropertyType < ApplicationRecord

	has_many :device_properties, foreign_key: :property_type, inverse_of: :property_type

end
