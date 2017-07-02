module Api
  module V1
    class DevicesController < ApplicationController
      skip_before_action :verify_authenticity_token, :only => [:status, :attributes_status_update]

      before_action :update_last_contact_time

      def attributes_list
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

      def attributes_status_update
        puts params.inspect
        render json: params
      end

      def status
        puts request.env.select {|k, v| k =~ /^HTTP_/}

        device_uid = params[:serial_number].to_i
        info       = params.except(:controller, :action)

        info.each do |key, value|
          device_stat = DeviceStat.where(device_uid: device_uid, stat_name: key).take

          if (!device_stat.nil?)
            device_stat.value          = value
            device_stat.last_update_at = Time.now # TODO correct the time is inserted to db
            device_stat.save()
          else
            device_stat                = DeviceStat.new
            device_stat.device_uid     = device_uid
            device_stat.stat_name      = key
            device_stat.value          = value
            device_stat.last_update_at = Time.now # TODO correct the time is inserted to db
            device_stat.save()
          end

        end

        render json: { status: 'OK' }, status: :ok
      end

      private def update_last_contact_time
                # TODO fix, abort execution if device uid not exists OR not saved
        device_uid = params[:serial_number].to_i
        if Device.exists?(device_uid)
          @device = Device.find(device_uid)
        else
          return false
        end
        @device.last_contact_at = Time.now
        if !@device.save
          return false
        end
      end

    end
  end
end
