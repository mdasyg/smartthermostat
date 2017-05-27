class Schedule < ApplicationRecord

  belongs_to :user, inverse_of: :schedules
  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :schedules
  has_one :event, inverse_of: :schedule

end
