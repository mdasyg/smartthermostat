class Event < ApplicationRecord

  belongs_to :schedule, inverse_of: :event
  has_many :actions, inverse_of: :event

end
