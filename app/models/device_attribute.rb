class DeviceAttribute < ApplicationRecord

  PRIMITIVE_TYPES = {
      INTEGER: { ID: 1, LABEL: 'Integer' },
      BOOL:    { ID: 2, LABEL: 'Bool' },
      FLOAT:   { ID: 3, LABEL: 'Float' },
      STRING:  { ID: 4, LABEL: 'String' },
      TEXT:    { ID: 5, LABEL: 'Text' },
  }

  DIRECTIONS = {
      SIGNALING_AND_FEEDBACK: { ID: 1, LABEL: 'Bi-directional' },
      SIGNALING_ONLY:         { ID: 2, LABEL: 'Signaling' },
      FEEDBACK_ONLY:          { ID: 3, LABEL: 'Feedback' },
  }

  validates :name, presence: true, length: { minimum: 1, maximum: 20 }
  validates :unit, length: { maximum: 5 }

  validates :unsigned, inclusion: { in: [true, false], message: "%{value} is not a valid state" }

  validates :primitive_type_c_id, inclusion: { in: [1, 2, 3, 4, 5], message: "'%{value}' is not a valid primitive type" }
  validates :direction_c_id, inclusion: { in: [1, 2, 3], message: "'%{value}' is not a valid direction" }

  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device_attributes
  has_many :actions, inverse_of: :device_attribute

end
