namespace :myrailsapp do
  desc "First try on tasks"
  task(:asdf, [:tasos] => [:environment]) do |t, args|
    puts 'Hello tasks!!!'
    puts t
    puts args

    puts Device.new
  end

  desc "First2 try on tasks"
  task(asdf2: :environment) do
    puts 'Hello tasks2!!!'
  end
end
