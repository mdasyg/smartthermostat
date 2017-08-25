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

        render plain: ActiveSupport::JSON.encode({ res: :ok })
      end

      def attributes_status_update
        if !params.has_key?(:da)
          render plain: ActiveSupport::JSON.encode({ msg: ['Device attributes missing'], res: :err }) and return
        end

        device_attributes_post = params[:da]
        device_attributes_post.each do |key, value|
          dev_attr = @device.device_attributes.where(id: value[:id]).take
          if (!dev_attr.nil?)
            dev_attr.current_value = value[:cur]
            dev_attr.save()
          else
            render plain: ActiveSupport::JSON.encode({ msg: ['Device attribute not exists'], res: :err }) and return
          end
        end

        render plain: ActiveSupport::JSON.encode({ res: :ok })
      end

      def attributes_list

        mqtt_client = Mosquitto::Client.new()

        # mqtt_client.on_connect {|rc|
        #   p "Connected with return code #{rc}"
        # }

        @device.device_attributes.each do |device_attribute|
          mqtt_client.connect('home-auto.eu', 1883, 10)
          payload = ActiveSupport::JSON.encode({ da: { id: device_attribute.id, name: device_attribute.name, set: device_attribute.set_value } })
          mqtt_client.publish(nil, @device.uid.to_s, payload, Mosquitto::AT_MOST_ONCE, false)
        end

        mqtt_client.disconnect()

        render plain: ActiveSupport::JSON.encode({ res: :ok })

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
