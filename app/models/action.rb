class Action < ApplicationRecord
	
	belongs_to :event, inverse_of: :actions
	belongs_to :device_property, inverse_of: :actions

end
