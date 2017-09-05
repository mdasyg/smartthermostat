class Schedule < ApplicationRecord

  validates :title, presence: true
  # validates :datetime, presence: true

  REPEAT_EVERY = {
      # MINUTE: { ID: 1, LABEL: 'Minutely' },
      # HOUR:   { ID: 2, LABEL: 'Hourly' },
      DAY:  { ID: 3, LABEL: 'Daily', SINGULAR: 'Day', PLURAL: 'Days' },
      WEEK: { ID: 4, LABEL: 'Weekly', SINGULAR: 'Week', PLURAL: 'Weeks' },
      # MONTH:  { ID: 5, LABEL: 'Monthly' },
      # YEAR:   { ID: 6, LABEL: 'Yearly' },
  }

  belongs_to :user, inverse_of: :schedules

  has_many :schedule_events, dependent: :destroy, autosave: true

end
