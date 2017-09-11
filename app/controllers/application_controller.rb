class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  VERSION = '0.0.1'

  SMART_THERMOSTAT_SAMPLE_RATE = 5

end
