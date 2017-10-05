include DevicesHelper

class HomeController < ApplicationController

  def index
    if user_signed_in?
      @total_devices_count = current_user.devices.count

      @offline_devices_count = 0
      current_user.devices.find_each do |device|
        if !device_online?(device.last_contact_at)
          @offline_devices_count += 1
        end
      end

    end
  end

end
