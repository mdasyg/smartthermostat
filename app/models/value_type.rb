class ValueType < ApplicationRecord
  PRIMITIVE_TYPES = {
      INTEGER: { ID: 1, LABEL: 'Integer' },
      FLOAT:   { ID: 2, LABEL: 'Float' },
  }

  has_many :device_properties, inverse_of: :value_type

end
