module DevicesHelper

  def send_new_schedule_table_to_device(device, mqtt_client)
    # Find the beggining and end of this day
    current_time = Time.current
    day_end      = current_time.end_of_day

    # acquire one time events for this day
    query_string = '(schedules.start_datetime BETWEEN :current_time AND :day_end)'
    query_string += ' OR '
    query_string += '(schedules.end_datetime BETWEEN :current_time AND :day_end)'
    query_string += ' OR '
    query_string += '(schedules.start_datetime <= :current_time AND :day_end <= schedules.end_datetime)'
    query_params = {
        current_time: current_time.time.to_formatted_s(:db),
        day_end:      day_end.time.to_formatted_s(:db)
    }

    device_schedule_events_from_single_scheules = device.schedule_events.joins(:schedule).where(schedules: { is_recurrent: false }).where(query_string, query_params).order('schedules.end_datetime, schedules.priority')

    device_schedule_events_from_single_scheules_count = device_schedule_events_from_single_scheules.size-1

    schedules_data_to_send = []
    device_schedule_events_from_single_scheules.each_with_index do |schedule_event, schedule_event_idx|
      puts schedule_event
      puts schedule_event_idx
      schedules_data_to_send << { start: schedule_event.schedule.start_datetime.time.to_i, end: schedule_event.schedule.end_datetime.time.to_i, recurrent: 0, priority: schedule_event.schedule.priority, actions: schedule_event.actions }
      if schedule_event_idx == (2-1)
        break
      end
    end

    # Do something for the recurrent events

    # First, tell the device to delete the schedules that already had, and wait for the new ones
    payload = ActiveSupport::JSON.encode({ sc_del: :all })
    mqtt_client.publish(device.uid.to_s, payload, false, 0)

    # Secondly, send the new schedules to the device
    schedules_data_to_send.each_with_index do |schedule_data, sc_idx|
      puts "EDW #{sc_idx}"
      schedule_event_actions = schedule_data[:actions]
      payload                = ActiveSupport::JSON.encode({ sc: { idx: sc_idx, s: schedule_data[:start], e: schedule_data[:end], r: schedule_data[:recurrent], p: schedule_data[:priority] } })
      mqtt_client.publish(device.uid.to_s, payload, false, 0)
      schedule_event_actions.each do |schedule_event_action|
        payload = ActiveSupport::JSON.encode(
            {
                sc_a: {
                    idx:    sc_idx,
                    da_idx: schedule_event_action.device_attribute.index_on_device,
                    start:  schedule_event_action.device_attribute_start_value,
                    end:    schedule_event_action.device_attribute_end_value,
                }
            }
        )
        mqtt_client.publish(device.uid.to_s, payload, false, 0)
      end
    end

  end

  def get_min_value_text(device_attribute_primitive_type, device_attribute_value)
    if device_attribute_value.nil?
      return 'N/A'
    else
      if (device_attribute_primitive_type == DeviceAttribute::PRIMITIVE_TYPES[:BOOL][:ID])
        return DeviceAttribute::BOOL_VALUES[:MIN][:LABEL]
      else
        return device_attribute_value
      end
    end
  end

  def get_max_value_text(device_attribute_primitive_type, device_attribute_value)
    if device_attribute_value.nil?
      return 'N/A'
    else
      if (device_attribute_primitive_type == DeviceAttribute::PRIMITIVE_TYPES[:BOOL][:ID])
        return DeviceAttribute::BOOL_VALUES[:MAX][:LABEL]
      else
        return device_attribute_value
      end
    end
  end

  def get_device_status_indication(device_last_contact_time)
    if device_last_contact_time.nil?
      return 'No contact yet'
    else
      time_diff = (Time.current() - device_last_contact_time).to_i
      if time_diff < Rails.application.secrets.configs[:time_diff_to_consider_device_as_active_in_seconds]
        return 'ONLINE'
      else
        return "OFFLINE (last contact #{distance_of_time_in_words(time_diff)} ago)"
      end
    end
  end

  def compute_device_attribute_set_or_current_value(device_attribute_primitive_type, device_attribute_value, asText = false)
    if device_attribute_value.nil?
      return (asText) ? 'N/A' : ''
    else
      if device_attribute_primitive_type == DeviceAttribute::PRIMITIVE_TYPES[:BOOL][:ID]
        if device_attribute_value == DeviceAttribute::BOOL_VALUES[:MAX][:ID]
          return (asText) ? DeviceAttribute::BOOL_VALUES[:MAX][:LABEL] : DeviceAttribute::BOOL_VALUES[:MAX][:ID].to_s
        else
          return (asText) ? DeviceAttribute::BOOL_VALUES[:MIN][:LABEL] : DeviceAttribute::BOOL_VALUES[:MIN][:ID].to_s
        end
      else
        return device_attribute_value
      end
    end
  end

end
