class ValidateActionValues < ActiveModel::Validator

  def validate(record)
    related_device_attribute = record.device_attribute
    # The start value
    if !record.device_attribute_start_value.nil?
      if record.device_attribute_start_value < related_device_attribute.min_value
        record.errors[:device_attribute_start_value] << 'Smaller than min value'
      elsif record.device_attribute_start_value > related_device_attribute.max_value
        record.errors[:device_attribute_start_value] << 'Bigger than max value'
      end
    end
    # The end value
    if !record.device_attribute_end_value.nil?
      if record.device_attribute_end_value < related_device_attribute.min_value
        record.errors[:device_attribute_end_value] << 'Smaller than min value'
      elsif record.device_attribute_end_value > related_device_attribute.max_value
        record.errors[:device_attribute_end_value] << 'Bigger than max value'
      end
    end
  end

end

class Action < ApplicationRecord

  validates :device_attribute_start_value, :device_attribute_end_value, presence: true

  validates_with ValidateActionValues

  belongs_to :device_attribute

  has_one :schedule_event_action
  has_one :schedule_event, through: :schedule_event_action

  has_one :quick_button_action
  has_one :quick_button, through: :quick_button_action

end
