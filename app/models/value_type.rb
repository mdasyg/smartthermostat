class ValueType < ApplicationRecord

	has_many :device_properties, foreign_key: :value_type, inverse_of: :value_type

end
