puts schedule.inspect

json.id schedule.id.to_s
json.name schedule.title
json.description schedule.description
json.start schedule.start_datetime
json.end schedule.end_datetime

json.schedule_events schedule.schedule_events.each do |schedule_event|
  json.id schedule_event.id.to_s
  json.device_uid schedule_event.device_uid.to_s
  json.device_name schedule_event.device.name
  json.actions do
    json.partial! partial: 'actions/action', collection: schedule_event.actions, as: :action
  end
end

# json.actions schedule.actions
# json.url schedule_url(schedule, format: :json)
