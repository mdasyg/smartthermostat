class ValueType < ApplicationRecord

	has_many :device_properties, inverse_of: :value_type

end
