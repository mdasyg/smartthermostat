class Action < ApplicationRecord

  # validates :device_attribute_start_value, presence: true

  belongs_to :device_attribute

  has_one :schedule_event_action
  has_one :schedule_event, through: :schedule_event_action

  has_one :quick_button_action
  has_one :quick_button, through: :quick_button_action

end
