class Action < ApplicationRecord

	validates :property_value, presence: true

	belongs_to :property

	has_one :event, dependent: :destroy
	has_one :schedule, through: :event

end
