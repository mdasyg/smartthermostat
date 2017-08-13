# Home Automation

# Requirements

1. ruby 2.3 or later
2. ruby-gems manager
3. bundler
4. [libmosquitto](https://github.com/xively/mosquitto)
5. mysql server
6. web server with phusion passenger module (e.g install passenger gem)

# Installation

## Initial setup

1. after all requirements met, run 'bundle install'
2. copy 'secrets.yml.sample' to 'secrets.yml' and change the appropriate values

## Database

1. set the following configurations on the general application file(config/application.rb) or in the environment specifiec files(config/environments/...)

	+ config.active_record.table_name_prefix
	+ config.active_record.table_name_suffix

2. setup a database on your DB
3. setup a user and give him access
4. run 'rails db:migrate'

## Mailer

1. set the following to config/environments/{enviroment_name}.rb

```
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               Rails.application.secrets.mail['domain'],
  user_name:            Rails.application.secrets.mail['username'],
  password:             Rails.application.secrets.mail['pass'],
  authentication:       'plain',
  enable_starttls_auto: true
}
```
2. Be sure to set a domain, otherwise email failing to send

3. change accordingly the from adress where needed
	+ eg: app/mailers/application_mailer.rb

Test emails with:
ActionMailer::Base.mail(from: "test@example.co", to: "valid.recipient@domain.com", subject: "Test", body: "Test").deliver

## Web-console whitelist

1. config.web_console.whitelisted_ips = '10.168.10.40'

# Notes

+ In production machines run `rake assets:precompile` in order to precompile assets and work properly

+ When using modules(e.g x-editable, bootstrap) because of assets some url/links doesnot work so yoy have to override them (see application.scss for example)

+ On "app/assets/javascripts/application.js" consider using "//= require bootstrap" instead of "//= require bootstrap-sprockets" when in production

+ When using javascript remember that rails uses turbolinks,
read [this](http://guides.rubyonrails.org/working_with_javascript_in_rails.html#page-change-events)
for more info. To workaround this we need to replace the '$(document).ready()' 
with '$(document).on("turbolinks:load", function() {})'
+ Use `puts request.env.select {|k, v| k =~ /^HTTP_/}` to print out on console HTTP headers

# Resources

+ Database [my-thesis-db-schema-design](https://dbdesigner.net/designer/schema/54771)
+ Wireframe [my-thesis-wireframe](https://app.mockflow.com/index.jsp?editor=on&publicid=Da8f54e4c4cd2adeb757a8f5723ca6d64&projectid=D09b31f58b04a901571e0d79f7f8e17c0&perm=Owner&template=)

