module DevicesHelper

  def compute_device_status_indication(device_last_contact_time)
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

  def compute_device_attribute_text(device_attribute_current_value, device_attribute_unit, device_attribute_last_update_time)
    if device_attribute_current_value.nil?
      return '-'
    else
      return_text = device_attribute_current_value.to_s + ' ' + device_attribute_unit
      # if device_attribute_last_update_time.nil?
      #   return return_text + ' (-)'
      # else
      #   return return_text + ' (' + distance_of_time_in_words(Time.current() - device_attribute_last_update_time) + ' ago)'
      # end
      return return_text
    end
  end

end
