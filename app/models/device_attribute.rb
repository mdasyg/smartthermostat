class ValidateDeviceAttributeValues < ActiveModel::Validator
  def validate(record)
    if record.direction_c_id == DeviceAttribute::DIRECTIONS[:SIGNALING_AND_FEEDBACK][:ID] || record.direction_c_id == DeviceAttribute::DIRECTIONS[:SIGNALING_ONLY][:ID]
      if record.primitive_type_c_id == DeviceAttribute::PRIMITIVE_TYPES[:BOOL][:ID]
        if record.set_value != 0 && record.set_value != 1
          record.errors[:set_value] << 'Illegal value for bool type'
        end
        return
      end
      if record.min_value.blank?
        record.errors[:min_value] << 'Missing'
      end
      if record.max_value.blank?
        record.errors[:max_value] << 'Missing'
      end
      if record.errors.any?
        return
      end
      if record.set_value < record.min_value
        record.errors[:set_value] << 'Smaller than min value'
      elsif record.set_value > record.max_value
        record.errors[:set_value] << 'Bigger than max value'
      end
    end
  end
end

class DeviceAttribute < ApplicationRecord

  PRIMITIVE_TYPES = {
      INTEGER: { ID: 1, LABEL: 'Integer' },
      FLOAT:   { ID: 2, LABEL: 'Float' },
      BOOL:    { ID: 3, LABEL: 'Bool' },
  }

  BOOL_VALUES = {
      MIN: { ID: 0, LABEL: 'OFF' },
      MAX: { ID: 1, LABEL: 'ON' },
  }

  DIRECTIONS = {
      SIGNALING_AND_FEEDBACK: { ID: 1, LABEL: 'Bi-directional' },
      SIGNALING_ONLY:         { ID: 2, LABEL: 'Signaling' },
      FEEDBACK_ONLY:          { ID: 3, LABEL: 'Feedback' },
  }

  validates :name, presence: true, length: { minimum: 1, maximum: 20 }

  validates :primitive_type_c_id, presence: true
  validates :primitive_type_c_id, inclusion: { in: [1, 2, 3], message: "'%{value}' is not a valid primitive type" }

  # validates :unsigned, presence: true # rails validation guide recomends the following commands, because internal working of presence makes 0 look as not presence
  # validates :unsigned, inclusion: { in: [true, false], message: "%{value} is not a valid state" }
  # validates :unsigned, exclusion: { in: [nil] }

  validates :direction_c_id, presence: true
  validates :direction_c_id, inclusion: { in: [1, 2, 3], message: "'%{value}' is not a valid direction" }

  validates :unit, length: { maximum: 5 }

  validates :min_value, numericality: true, allow_nil: true
  validates :max_value, numericality: true, allow_nil: true
  validates :set_value, numericality: true, allow_nil: true
  validates :current_value, numericality: true, allow_nil: true

  validates_with ValidateDeviceAttributeValues

  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device_attributes
  has_many :actions, inverse_of: :device_attribute
  has_many :smart_thermostats, foreign_key: :source_device_attribute_id, inverse_of: :device_attribute

end
