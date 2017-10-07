class UserMailer < ApplicationMailer

  def notify_user_for_offline_devices(offline_device)

    @user = offline_device.user
    @device_name = offline_device.name
    @offline_device_time_for_send_notification = Rails.application.secrets.configs[:send_email_notification_after_device_offine_period_in_minutes]

    mail(to: @user.email, subject: 'Offline device notification')
  end

end
