json.id schedule.id.to_s
json.original_schedule schedule.original_schedule
json.title schedule.title
json.description schedule.description
json.start schedule.start_datetime
json.end schedule.end_datetime
json.priority schedule.priority
json.is_recurrent schedule.is_recurrent
json.recurrence_frequency schedule.recurrence_frequency
json.recurrence_unit schedule.recurrence_unit

json.schedule_events schedule.schedule_events.each do |schedule_event|
  json.id schedule_event.id.to_s
  json.device_uid schedule_event.device_uid.to_s
  json.device_name schedule_event.device.name
  json.actions do
    json.partial! partial: 'actions/action', collection: schedule_event.actions, as: :action
  end
end
