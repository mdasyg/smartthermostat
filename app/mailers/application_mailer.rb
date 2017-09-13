class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.mail[:from]
  layout 'mailer'
end
