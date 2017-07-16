json.id schedule.id.to_s
json.name schedule.title
json.description schedule.description
json.start schedule.start_datetime
json.end schedule.end_datetime

json.schedule_events schedule.schedule_events.each do |event|
  json.device_name event.device.name
  json.actions do
    json.partial! partial: 'actions/action', collection: event.actions, as: :action
  end
end


# json.actions schedule.actions


# json.url schedule_url(schedule, format: :json)
