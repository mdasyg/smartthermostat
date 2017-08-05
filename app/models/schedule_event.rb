class ScheduleEvent < ApplicationRecord

  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :schedule_events
  belongs_to :schedule

  has_many :schedule_events_actions
  has_many :actions, through: :schedule_events_actions, dependent: :destroy, autosave: true

end