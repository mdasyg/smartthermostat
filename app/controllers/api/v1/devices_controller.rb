module Api
  module V1
    class DevicesController < ApplicationController
      skip_before_action :verify_authenticity_token, :only => [:stats_update, :attributes_status_update, :attributes_list]
      before_action :set_device # order matters
      before_action :update_last_contact_time

      # POST /devices/1/stats_update
      # POST /devices/1/stats_update.json
      def stats_update
        device_uid = @device.uid
        extra_info = params.except(:controller, :action, :uid)

        extra_info.each do |key, value|
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

        render json: { result: :ok }
      end

      def attributes_status_update
        if !params.has_key?(:dev_attr)
          render json: { messages: ['Device attributes missing'], result: :error } and return
        end

        device_attributes_post = params[:dev_attr]
        device_attributes_post.each do |key, value|
          dev_attr               = @device.device_attributes.where(id: value[:id]).take
          dev_attr.current_value = value[:curVal]
          dev_attr.save()
        end

        render json: { result: :ok }
      end

      # def attributes_list
      #   # if !params.has_key?(:dev_uid)
      #   #   render json: { status: :error, msg: ['Device UID is missing'] }, status: :bad_request and return
      #   # end
      #   #
      #   # begin
      #   #   @device = Device.find(params[:dev_uid])
      #   # rescue ActiveRecord::RecordNotFound
      #   #   respond_to do |format|
      #   #     format.json {render json: { status: :error, msg: ['Device UID not exists'] }, status: :not_found and return}
      #   #   end
      #   # end
      #
      #   respond_to do |format|
      #     format.json {render json: { status: :ok, msg: @device.device_attributes }, status: :ok}
      #   end
      # end

      ##########################################################################
      ##### PRIVATE METHODS ####################################################
      ##########################################################################
      private def set_device
        if !params.has_key?(:uid)
          render json: { messages: ['Device UID is missing'], result: :error } and return
        end

        begin
          @device = Device.find(params[:uid])
        rescue ActiveRecord::RecordNotFound
          render json: { messages: ['Device UID not exists'], result: :error } and return
        end
      end

      private def update_last_contact_time
        @device.last_contact_at = Time.now
        if !@device.save
          render json: { messages: ['Internal server error'], result: :error } and return
        end
      end

    end
  end
end
