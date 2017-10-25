namespace :devices do

  desc 'Check which devices are offline for a certain amount of time and send notification to user owner'
  task(:send_offline_notifications => [:environment]) do |t, args|
    offline_period       = Rails.application.secrets.configs[:send_email_notification_after_device_offine_period_in_minutes]
    current_time         = Time.now
    minimum_offline_time = current_time.ago(offline_period.minutes).to_formatted_s(:db)

    query_string = 'long_offline_time_notification_status = :long_offline_time_notification_status'
    query_string += ' AND '
    query_string += 'last_contact_at <= :minimum_offline_time'
    query_params = {
        minimum_offline_time:                  minimum_offline_time,
        long_offline_time_notification_status: Device::OFFLINE_NOTIFICATION_STATUS[:NOT_SEND]
    }

    offline_devices_to_send_notification_for = Device.where([query_string, query_params])

    offline_devices_to_send_notification_for.find_each do |offline_device|
      UserMailer.notify_user_for_offline_devices(offline_device).deliver_now
      offline_device.long_offline_time_notification_status = Device::OFFLINE_NOTIFICATION_STATUS[:EMAIL_SEND]
      offline_device.save
    end
  end

end
