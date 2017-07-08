class Action < ApplicationRecord

	validates :device_attribute_value, presence: true

	belongs_to :device_attribute

	has_one :event, dependent: :destroy
	has_one :schedule, through: :event

end
