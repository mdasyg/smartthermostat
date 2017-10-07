json.array! @schedules, partial: 'schedules/schedule', as: :schedule
json.array! @recurrent_schedules_array, partial: 'schedules/schedule', as: :schedule