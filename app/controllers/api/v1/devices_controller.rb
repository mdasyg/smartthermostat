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

    end
  end
end
