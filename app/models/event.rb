class Event < ApplicationRecord

  belongs_to :schedule
  belongs_to :action

end
