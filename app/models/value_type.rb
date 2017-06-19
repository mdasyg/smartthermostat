class ValueType < ApplicationRecord
  PRIMITIVE_TYPES = {
      INTEGER: { ID: 1, LABEL: 'Integer' },
      BOOL:    { ID: 2, LABEL: 'Bool' },
      FLOAT:   { ID: 3, LABEL: 'Float' },
      STRING:  { ID: 4, LABEL: 'String' },
      TEXT:    { ID: 5, LABEL: 'Text' },
  }

  validates :name, presence: true
  validates :unsigned, inclusion: { in: [true, false], message: "%{value} is not a valid state" }
  validates :primitive_type_id, inclusion: { in: [1, 2, 3, 4, 5], message: "'%{value}' is not a valid primitive value" }

  has_many :device_attributes, inverse_of: :value_type

end
