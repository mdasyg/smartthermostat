# Home Automation

# Requirements

+ ruby
+ rails
+ passenger gem for apache (phuion passenger module)
+ device gem

# Installation

## Initial setup

+ rails configs keys,e.t.c
+ devise
+ secrets.yml

## Database

set the following configurations on the general application file(config/application.rb) or in the environment specifiec files(config/environments/...)

+ config.active_record.table_name_prefix
+ config.active_record.table_name_suffix

## Mailer

set the following to config/environments/<enviroment>.rd 
and set the appropriate secrets on config/secrets.yml

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
    address:              'smtp.gmail.com',
    port:                 587,
    domain:               'tasloum.eu',
    user_name:            Rails.application.secrets.mail_username,
    password:             Rails.application.secrets.mail_pass,
    authentication:       'plain',
    enable_starttls_auto: true
}

change accordingly the from adress where needed.
eg: app/mailers/application_mailer.rb

Test emails with:
ActionMailer::Base.mail(from: "test@example.co", to: "valid.recipient@domain.com", subject: "Test", body: "Test").deliver

## Web-console whitelist

config.web_console.whitelisted_ips = '10.168.10.40'

# Notes

+ On "app/assets/javascripts/application.js" consider using "//= require bootstrap" instead of "//= require bootstrap-sprockets" when in production

+ When using javascript remember that rails uses turbolinks,
read [this](http://guides.rubyonrails.org/working_with_javascript_in_rails.html#page-change-events)
for more info. To workaround this we need to replace the '$(document).ready()' 
with '$(document).on("turbolinks:load", function() {})'


# Resources

+ Database [my-thesis-db-schema-design](https://dbdesigner.net/designer/schema/54771)
+ Wireframe [my-thesis-wireframe](https://app.mockflow.com/index.jsp?editor=on&publicid=Da8f54e4c4cd2adeb757a8f5723ca6d64&projectid=D09b31f58b04a901571e0d79f7f8e17c0&perm=Owner&template=)

