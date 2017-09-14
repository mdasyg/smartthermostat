# Device Manager

'Device Manager' is project it's creation started for the purposes of my thesis, with the title 'Design and implementation of the infrastructure of an intelligent ecological house'.

# Requirements

1. Ruby v2.3 or later
2. RubyGems manager
3. MySQL database server
4. A Web server with phusion passenger module installed and enabled(e.g install passenger gem) ([installation instructions](https://www.phusionpassenger.com/library/install/standalone/install/oss/))
5. Latest NodeJs
6. Mosquitto Broker
7. Bundler
8. Yarn dependency manager for front-end dependencies ([installation instructions](https://yarnpkg.com/en/docs/install))

# Installation

## Initial setup

1. Install the project's required software
2. Download the project and go to project's root directory
3. Copy `secrets.yml.sample` to `secrets.yml` and change the appropriate values
4. Run `bundle install`
5. Run `yarn install`

## Database

1. Create a database on MySQL
2. Setup a user and give him access to the previously created db
3. Be careful to set this information on `secrets.yml`
4. Run `rails db:migrate`

## Mailer

1. Be sure to set a domain in mail section settings, otherwise email fail to send
2. Be sure to set the from email address in mail section settings, otherwise email fail to send
3. Test email delivery with:
`ActionMailer::Base.mail(from: "test@example.co", to: "valid.recipient@domain.com", subject: "Test", body: "Test").deliver`, on rails console

## Cron setup

+ There some tasks that need to be run repeatedly, so you must setup cron for them

```cron
*/5 * * * * cd /var/www/html/home-auto && /home/vagrant/.rvm/wrappers/ruby-2.4.1/rake RAILS_ENV=development smart_thermostat:history_sample
# One more here
*/5 * * * * cd /var/www/html/home-auto && /home/vagrant/.rvm/wrappers/ruby-2.4.1/rake RAILS_ENV=development smart_thermostat:send_notification_for_offline_devices
```

+ To get more info about the tasks, look at the `lib/tasks`

## web-console white-list ips

1. Set your developments' machines ips in the web-console configuration on the secrets as an array of strings. `e.g ['192.168.1.2', '192.168.1.3']`

# Notes

+ In production machines run `rake assets:precompile` in order to precompile assets and work properly

+ When using modules (e.g x-editable, bootstrap) because of assets some url/links doesn't work, so you have to override them (see application.scss for example)

+ when using nginx as reverse proxy use the following settings

```nginx
location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Ssl on;
}
```

+ When using javascript remember that this project uses turbolinks, read [this](http://guides.rubyonrails.org/working_with_javascript_in_rails.html#page-change-events) for more info. To workaround `$(document).ready(function() {})` not working, you must replace it with `$(document).on("turbolinks:load", function() {})`

+ Use `puts request.env.select {|k, v| k =~ /^HTTP_/}` to print out on console HTTP headers

+ For time, use the `Time.current`, for getting timestamp append `.to_i`

# Resources

+ [Rails internals](http://andrewberls.com/blog/post/rails-from-request-to-response-part-1--introduction)

+ [Rails init](http://guides.rubyonrails.org/initialization.html)

+ Wireframe [my-thesis-wireframe](https://app.mockflow.com/index.jsp?editor=on&publicid=Da8f54e4c4cd2adeb757a8f5723ca6d64&projectid=D09b31f58b04a901571e0d79f7f8e17c0&perm=Owner&template=)
