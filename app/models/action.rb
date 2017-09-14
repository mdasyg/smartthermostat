class ValidateActionValues < ActiveModel::Validator
  def validate(record)
    related_device_attribute = record.device_attribute

    puts record.device_attribute_start_value
    puts record.device_attribute_end_value

    puts related_device_attribute.min_value
    puts related_device_attribute.max_value

    # The start value
    if !record.device_attribute_start_value.nil?
      puts "STart value not nil"
      if record.device_attribute_start_value < related_device_attribute.min_value
        puts 'Start value smaller than min'
        record.errors[:device_attribute_start_value] << 'Smaller than min value'
      elsif record.device_attribute_start_value > related_device_attribute.max_value
        puts 'Start value bigger than max'
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

    puts record.errors.messages

  end
end

class Action < ApplicationRecord

  validates_with ValidateActionValues

  belongs_to :device_attribute

  has_one :schedule_event_action
  has_one :schedule_event, through: :schedule_event_action

  has_one :quick_button_action
  has_one :quick_button, through: :quick_button_action

end
