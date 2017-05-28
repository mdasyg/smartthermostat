class ValueType < ApplicationRecord
  PRIMITIVE_TYPES = {
      INTEGER: { ID: 1, LABEL: 'Integer' },
      FLOAT:   { ID: 2, LABEL: 'Float' },
      STRING:  { ID: 3, LABEL: 'String' },
      TEXT:    { ID: 4, LABEL: 'Text' },
  }

  validates :name, :primitive_type_id, :unsigned, presence: true

  has_many :properties, inverse_of: :value_type

end
