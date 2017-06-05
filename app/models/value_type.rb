class ValueType < ApplicationRecord
  PRIMITIVE_TYPES = {
      INTEGER: { ID: 1, LABEL: 'Integer' },
      FLOAT:   { ID: 2, LABEL: 'Float' },
      STRING:  { ID: 3, LABEL: 'String' },
      TEXT:    { ID: 4, LABEL: 'Text' },
  }

  validates :name, presence: true
  validates :unsigned, inclusion: { in: [true, false], message: "%{value} is not a valid state" }
  validates :primitive_type_id, inclusion: { in: [1, 2, 3, 4], message: "'%{value}' is not a valid primitive value" }

  has_many :properties, inverse_of: :value_type

end
