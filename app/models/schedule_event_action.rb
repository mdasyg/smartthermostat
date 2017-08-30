class ScheduleEventAction < ApplicationRecord

  belongs_to :schedule_event
  belongs_to :action

end