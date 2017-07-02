module Api
  module V1
    class DevicesController < ApplicationController
      skip_before_action :verify_authenticity_token, :only => [:status]

      def attributes
        if Device.exists?(params[:uid])
          @device = Device.find(params[:uid])
        else
          @device = nil
        end
        respond_to do |format|
          if @device
            # puts render_to_string(json: @device.device_attributes, status: :ok)
            format.json {render :json => @device.device_attributes, status: :ok}
          else
            format.json {render json: nil, status: :not_found}
          end
        end
      end

      def status

        puts request.env.select {|k, v| k =~ /^HTTP_/}

        device_uid = params[:serial_number].to_i
        info       = params.except(:controller, :action)

        info.each do |key, value|

          puts key
          puts value

          device_stat = DeviceStat.where(device_uid: device_uid, stat_name: key).take

          if (!device_stat.nil?)
            puts(device_stat.inspect)
            device_stat.value          = value
            device_stat.last_update_at = Time.now # TODO correct the time is inserted to db
            device_stat.save()
            puts(device_stat.inspect)
          else
            puts('Stat not exists')
            device_stat = DeviceStat.new
            device_stat.device_uid = device_uid
            device_stat.stat_name = key
            device_stat.value = value
            device_stat.last_update_at = Time.now # TODO correct the time is inserted to db
            device_stat.save()
          end

        end

        render json: 'OK', status: :ok

      end

    end
  end
end
