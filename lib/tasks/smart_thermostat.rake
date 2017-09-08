namespace :smart_thermostat do

  desc 'Take sample from device attributes for smart thermostat history and training'
  task(:history_sample, [:arg1] => [:environment]) do |t, args|
    puts 'Hello tasks!!!'
    puts t
    puts args
  end

end
