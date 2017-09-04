module DevicesHelper

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
