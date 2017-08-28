module Api
  module V1
    class DevicesController < ApplicationController
      skip_before_action :verify_authenticity_token, :only => [:stats_update, :attributes_status_update, :attributes_list]
      before_action :set_device # order matters, before 'update_last_contact_time'
      before_action :update_last_contact_time

      # POST /devices/1/stats_update
      # POST /devices/1/stats_update.json
      def stats_update
        device_uid = @device.uid
        stats_info = params.except(:controller, :action, :uid)

        stats_info.each do |key, value|
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

        render plain: ActiveSupport::JSON.encode({ res: :ok })
      end

      # POST /devices/1/attributes_status_update
      # POST /devices/1/attributes_status_update.json
      def attributes_status_update
        if !params.has_key?(:da)
          render plain: ActiveSupport::JSON.encode({ msg: ['Device attributes missing'], res: :err }) and return
        end

        device_attributes_post = params[:da]
        device_attributes_post.each do |key, device_attribute|
          dev_attr = @device.device_attributes.where(id: device_attribute[:id]).take
          if (!dev_attr.nil?)
            puts device_attribute
            puts dev_attr.inspect
            dev_attr.current_value = device_attribute[:cur]
            dev_attr.set_value     = device_attribute[:set]
            puts dev_attr.inspect
            dev_attr.save()
            puts dev_attr.errors.inspect
          else
            render plain: ActiveSupport::JSON.encode({ msg: ['Device attribute not exists'], res: :err }) and return
          end
        end

        render plain: ActiveSupport::JSON.encode({ res: :ok })
      end

      # GET /devices/1/get_info
      def get_info
        # inform client that all is ok
        render plain: ActiveSupport::JSON.encode({ res: :ok })

        # and now send to the device the requested info
        if params.has_key?(:t)

          request_type = params[:t]

          if request_type == 'all' || request_type == 'da'
            mqtt_client = Mosquitto::Client.new()
            @device.device_attributes.each do |device_attribute|
              mqtt_client.connect(Rails.application.secrets.mqtt[:host], Rails.application.secrets.mqtt[:port], 10)
              payload = ActiveSupport::JSON.encode({ da: { idx: device_attribute.index_on_device, id: device_attribute.id, name: device_attribute.name, set: device_attribute.set_value } })
              mqtt_client.publish(nil, @device.uid.to_s, payload, Mosquitto::AT_MOST_ONCE, false)
            end
            mqtt_client.disconnect()
          elsif request_type == 'all' || request_type == 'schedule'
            puts 'give schedule'
          elsif request_type == 'all' || request_type == 'dqb'
            puts 'give quick buttons'
          end

        end

      end

      ##########################################################################
      ##### PRIVATE METHODS ####################################################
      ##########################################################################
      private def set_device
        if !params.has_key?(:uid)
          render plain: ActiveSupport::JSON.encode({ msg: ['Device UID is missing'], res: :err }) and return
        end

        begin
          @device = Device.find(params[:uid])
        rescue ActiveRecord::RecordNotFound
          render plain: ActiveSupport::JSON.encode({ msg: ['Device UID not exists'], res: :err }) and return
        end
      end

      private def update_last_contact_time
        @device.last_contact_at = Time.now
        if !@device.save
          render plain: ActiveSupport::JSON.encode({ msg: ['Internal server err'], res: :err }) and return
        end
      end

    end
  end
end
