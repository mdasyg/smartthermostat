class Action < ApplicationRecord

	validates :property_value, presence: true

	belongs_to :event, inverse_of: :actions
	belongs_to :property, inverse_of: :actions

end
