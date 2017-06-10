class Schedule < ApplicationRecord

  REPAT_EVERY = {
      MINUTE: { ID: 1, LABEL: 'Minute' },
      HOUR:   { ID: 2, LABEL: 'Hour' },
      DAY:    { ID: 3, LABEL: 'Day' },
      WEEK:   { ID: 4, LABEL: 'Week' },
      MONTH:  { ID: 5, LABEL: 'Month' },
      YEAR:   { ID: 6, LABEL: 'Year' },
  }

  belongs_to :user, inverse_of: :schedules
  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :schedules
  belongs_to :event, inverse_of: :schedule

end
