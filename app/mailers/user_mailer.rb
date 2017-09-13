class UserMailer < ApplicationMailer

  def notify_user_for_offline_devices(user)

    puts user
    puts user.email

    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

end
