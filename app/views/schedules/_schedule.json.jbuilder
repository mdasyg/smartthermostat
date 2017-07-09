json.id schedule.id.to_s
json.device_uid schedule.device_uid.to_s
json.name schedule.title
json.start schedule.datetime

json.actions schedule.actions


# json.url schedule_url(schedule, format: :json)
