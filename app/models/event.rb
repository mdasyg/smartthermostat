class Event < ApplicationRecord

  has_one :schedule, inverse_of: :event
  has_many :actions, inverse_of: :event

end
