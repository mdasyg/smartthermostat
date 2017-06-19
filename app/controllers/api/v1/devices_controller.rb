module Api
  module V1
    class DevicesController < ApplicationController

      def attributes
        if Device.exists?(params[:uid])
          @device = Device.find(params[:uid])
        else
          @device = nil
        end
        respond_to do |format|
          if @device
            format.json {render json: @device.device_attributes, status: :ok}
          else
            format.json {render json: nil, status: :not_found}
          end
        end
      end

      # def statusUpdate
      #
      #   device_uid = params[:device_uid].to_i
      #   info       = params.except(:controller, :action, :device_uid)
      #
      #   info.each do |key, value|
      #     stat_id = key.to_i
      #     if (stat_id > 0)
      #       device_stat = DeviceStat.where(device_uid: device_uid, stat_id: stat_id).take
      #
      #       if (!device_stat.nil?)
      #         puts(device_stat.inspect)
      #         device_stat.value          = value
      #         device_stat.last_update_at = Time.now # TODO correct the time is inserted to db
      #         device_stat.save()
      #         puts(device_stat.inspect)
      #       end
      #
      #     end
      #   end
      #
      #   render json: info.inspect.to_s
      # end

    end
  end
end
