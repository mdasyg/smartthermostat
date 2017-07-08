module Api
  module V1
    class DevicesController < ApplicationController
      skip_before_action :verify_authenticity_token, :only => [:status, :attributes_status_update, :attributes_list]
      before_action :update_last_contact_time

      def attributes_list
        if !params.has_key?(:dev_uid)
          render json: { status: :error, msg: ['Device UID is missing'] }, status: :bad_request and return
        end

        begin
          @device = Device.find(params[:dev_uid])
        rescue ActiveRecord::RecordNotFound
          respond_to do |format|
            format.json {render json: { status: :error, msg: ['Device UID not exists'] }, status: :not_found}
          end
        end

        respond_to do |format|
          format.json {render json: { status: :ok, msg: @device.device_attributes }, status: :ok}
        end
      end

      def attributes_status_update # remove '_update'
        # puts params.inspect
        render json: params
      end

      def status
        device_uid = params[:dev_uid].to_i
        info       = params.except(:controller, :action, :dev_uid)

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

        render json: { status: :ok }, status: :ok
      end

      private def update_last_contact_time
        if !params.has_key?(:dev_uid)
          render json: { status: :error, msg: ['Device UID is missing'] }, status: :bad_request and return
        end

        device_uid = params[:dev_uid].to_i
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
