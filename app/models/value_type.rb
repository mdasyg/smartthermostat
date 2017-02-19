class ValueType < ApplicationRecord

	belongs_to :property_type, inverse_of: :value_types

end
