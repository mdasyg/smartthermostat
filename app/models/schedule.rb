class Schedule < ApplicationRecord

  # validates :datetime, presence: true
  # validates :title, presence: true

  REPEAT_EVERY = {
      MINUTE: { ID: 1, LABEL: 'Minute' },
      HOUR:   { ID: 2, LABEL: 'Hour' },
      DAY:    { ID: 3, LABEL: 'Day' },
      WEEK:   { ID: 4, LABEL: 'Week' },
      MONTH:  { ID: 5, LABEL: 'Month' },
      YEAR:   { ID: 6, LABEL: 'Year' },
  }

  belongs_to :user, inverse_of: :schedules

  has_many :schedule_events

end
