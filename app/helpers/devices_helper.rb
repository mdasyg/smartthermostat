module DevicesHelper

  private def asdf(schedule_event)
    # Check if data from smart thermostat for this schedule temps exists
    # First check if device is smart thermostat
    start_time_offset = 0
    if schedule_event.device.type_c_id == Device::TYPES[:SMART_THERMOSTAT][:ID]
      puts 'SMART THERMOSTAT DEVICE'
      smart_thermostat_attributes_associations = SmartThermostat.where(smart_device_uid: schedule_event.device_uid)
      if smart_thermostat_attributes_associations.any?
        # Get current outside temp
        outside_temp_device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:OUTSIDE_TEMPERATURE][:ID]).source_device_attribute_id
        current_outside_temperature      = DeviceAttribute.find(outside_temp_device_attribute_id).current_value
        return start_time_offset if current_outside_temperature.blank?
        current_outside_temperature = current_outside_temperature.round(0)
        # Get current inside temp
        inside_temp_device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:INSIDE_TEMPERATURE][:ID]).source_device_attribute_id
        current_inside_temperature      = DeviceAttribute.find(inside_temp_device_attribute_id).current_value.round(1)
        # Get desired inside temp
        desired_inside_temperature = schedule_event.actions.find_by(device_attribute_id: inside_temp_device_attribute_id).device_attribute_start_value

        query_string = 'device_uid = :device_uid'
        query_string += ' AND '
        query_string += 'outside_temperature = :current_outside_temp'
        query_string += ' AND '
        query_string += '(inside_temperature = :current_inside_temp'
        query_string += ' OR '
        query_string += 'inside_temperature = :desired_inside_temp)'
        query_params = {
            device_uid:           schedule_event.device_uid,
            current_outside_temp: current_outside_temperature,
            current_inside_temp:  current_inside_temperature,
            desired_inside_temp:  desired_inside_temperature
        }

        smart_thermostat_temp_analysis = SmartThermostatComputedDataset.where([query_string, query_params]).order(:timeline)

        if smart_thermostat_temp_analysis.size == 2
          start_time_offset = smart_thermostat_temp_analysis[1].timeline - smart_thermostat_temp_analysis[0].timeline
        end
      end
    end
    return start_time_offset
  end

  def send_new_schedule_table_to_device(device, mqtt_client)
    # Find the beggining and end of this day
    current_time = Time.now
    day_end      = current_time.end_of_day

    puts current_time
    puts day_end

    # acquire one time events for this day
    query_string = '(schedules.start_datetime BETWEEN :current_time AND :day_end)'
    query_string += ' OR '
    query_string += '(schedules.end_datetime BETWEEN :current_time AND :day_end)'
    query_string += ' OR '
    query_string += '(schedules.start_datetime <= :current_time AND schedules.end_datetime >= :day_end)'
    query_params = {
        current_time: current_time.to_formatted_s(:db),
        day_end:      day_end.to_formatted_s(:db)
    }

    device_schedule_events_from_single_time_schedules = device.schedule_events.joins(:schedule).where(schedules: { is_recurrent: false }).where(query_string, query_params).order('schedules.start_datetime, schedules.priority')

    puts device_schedule_events_from_single_time_schedules.to_sql

    puts "POU EISAI?"
    pp device_schedule_events_from_single_time_schedules

    schedule_data_to_sort       = []
    left_over_events            = []
    next_schedule_event_checked = false
    device_schedule_events_from_single_time_schedules.each do |schedule_event| # Use each. otherwise order is not working.

      puts "CHecking Schedule Event"
      pp schedule_event

      puts schedule_event.schedule.start_datetime.to_formatted_s(:db)
      puts schedule_event.schedule.end_datetime.to_formatted_s(:db)

      puts current_time.to_formatted_s(:db) >= schedule_event.schedule.start_datetime.to_formatted_s(:db)
      puts current_time.to_formatted_s(:db) < schedule_event.schedule.end_datetime.to_formatted_s(:db)

      if current_time.to_formatted_s(:db) >= schedule_event.schedule.start_datetime.to_formatted_s(:db) && current_time.to_formatted_s(:db) < schedule_event.schedule.end_datetime.to_formatted_s(:db)
        schedule_data_to_sort << { start: schedule_event.schedule.start_datetime, end: schedule_event.schedule.end_datetime, recurrent: 0, priority: schedule_event.schedule.priority, actions: schedule_event.actions }
      else
        if !next_schedule_event_checked

          start_time_offset = asdf(schedule_event)

          puts "OFFSET START TIME #{start_time_offset} secs"

          # Subtract the offset from current schedule start time
          puts schedule_event.schedule.start_datetime
          schedule_event.schedule.start_datetime = schedule_event.schedule.start_datetime.advance(seconds: -start_time_offset)
          puts schedule_event.schedule.start_datetime

          schedule_data_to_sort.each do |schedule_data|
            puts schedule_event.schedule.start_datetime
            puts schedule_data[:end]
            if schedule_event.schedule.start_datetime < schedule_data[:end]
              schedule_data_to_sort << { start: schedule_event.schedule.start_datetime, end: schedule_event.schedule.end_datetime, recurrent: 0, priority: schedule_event.schedule.priority, actions: schedule_event.actions }
              next_schedule_event_checked = true
            end
          end
          if !next_schedule_event_checked
            left_over_events << { start: schedule_event.schedule.start_datetime, end: schedule_event.schedule.end_datetime, recurrent: 0, priority: schedule_event.schedule.priority, actions: schedule_event.actions }
            next_schedule_event_checked = true
          end
        else
          left_over_events << { start: schedule_event.schedule.start_datetime, end: schedule_event.schedule.end_datetime, recurrent: 0, priority: schedule_event.schedule.priority, actions: schedule_event.actions }
        end
      end
    end

    puts "TO SORT"
    schedule_data_to_sort.each do |sc|
      puts sc.inspect
    end

    puts "LEFT OVERS"
    puts left_over_events.inspect


    schedule_data_sorted = schedule_data_to_sort.sort do |sc1, sc2|
      sc1[:priority] <=> sc2[:priority]
    end

    left_over_events.each do |left_over_sc|
      schedule_data_sorted << left_over_sc
    end

    puts "SORTED?"
    schedule_data_sorted.each do |sc|
      puts sc.inspect
    end

    # Do something for the recurrent events
    if schedule_data_sorted.size < device.number_of_schedules
      # acquire recurrent events for this day

      #
      # query_string = '(schedules.start_datetime BETWEEN :current_time AND :day_end)'
      # query_string += ' OR '
      # query_string += '(schedules.end_datetime BETWEEN :current_time AND :day_end)'
      # query_string += ' OR '
      # query_string += '(schedules.start_datetime <= :current_time AND schedules.end_datetime >= :day_end)'
      # query_params = {
      #     current_time: current_time.to_time.to_formatted_s(:db),
      #     day_end:      day_end.to_time.to_formatted_s(:db)
      # }

      device_schedule_events_from_recurrent_schedules = device.schedule_events.joins(:schedule).where(schedules: { is_recurrent: true }).order('schedules.created_at, schedules.priority')

      puts "RECURRENT"
      puts device_schedule_events_from_recurrent_schedules.inspect

      current_day   = current_time.day
      current_month = current_time.month
      current_year  = current_time.year

      puts current_day
      puts current_month
      puts current_year

      device_schedule_events_from_recurrent_schedules.each do |schedule_event|
        frequency = nil
        if schedule_event.schedule.recurrence_unit == Schedule::REPEAT_EVERY[:DAY][:ID]
          frequency = schedule_event.schedule.recurrence_frequency.day.to_i
        elsif schedule_events.chedule.recurrence_unit == Schedule::REPEAT_EVERY[:WEEK][:ID]
          frequency = schedule_event.schedule.recurrence_frequency.week.to_i
        end
        schedule_data_sorted << { start: schedule_event.schedule.start_datetime.change(day: current_day, month: current_month, year: current_year), end: schedule_event.schedule.end_datetime.change(day: current_day, month: current_month, year: current_year), recurrent: frequency, priority: schedule_event.schedule.priority, actions: schedule_event.actions }
      end

    end

    # First, tell the device to delete the schedules that already had, and wait for the new ones
    payload = ActiveSupport::JSON.encode({ sc_del: :all })
    puts payload
    mqtt_client.publish(device.uid.to_s, payload, false, 0)

    # Secondly, send the new schedules to the device
    schedule_data_sorted.each_with_index do |schedule_data, sc_idx|
      puts "EDW #{sc_idx}"
      schedule_event_actions = schedule_data[:actions]
      payload                = ActiveSupport::JSON.encode({ sc: { idx: sc_idx, s: schedule_data[:start].time.to_i, e: schedule_data[:end].time.to_i, r: schedule_data[:recurrent], p: schedule_data[:priority] } })
      puts payload
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
      if sc_idx == (device.number_of_schedules-1)
        break
      end
    end
  end

  def get_min_value_text(device_attribute_primitive_type, device_attribute_value)
    if device_attribute_value.nil?
      return '-'
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
      return '-'
    else
      if (device_attribute_primitive_type == DeviceAttribute::PRIMITIVE_TYPES[:BOOL][:ID])
        return DeviceAttribute::BOOL_VALUES[:MAX][:LABEL]
      else
        return device_attribute_value
      end
    end
  end

  def get_device_online_status(device_last_contact_time)
    if device_last_contact_time.nil?
      return 'No contact yet'
    else
      time_diff = (Time.now() - device_last_contact_time.to_formatted_s(:db).to_time).to_i.abs
      if time_diff < Rails.application.secrets.configs[:time_diff_to_consider_device_as_active_in_seconds]
        return 'ONLINE'
      else
        return "OFFLINE (last contact #{distance_of_time_in_words(time_diff)} ago)"
      end
    end
  end

  def device_online?(device_last_contact_time)
    if device_last_contact_time.nil?
      return false
    else
      time_diff = (Time.now() - device_last_contact_time.to_formatted_s(:db).to_time).to_i.abs
      if time_diff < Rails.application.secrets.configs[:time_diff_to_consider_device_as_active_in_seconds]
        return true
      else
        return false
      end
    end
  end

  def compute_device_attribute_set_or_current_value(device_attribute_primitive_type, device_attribute_value, asText = false)
    if device_attribute_value.nil?
      return (asText) ? '-' : ''
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
