class DevicesController < ApplicationController
  # skip_before_action :verify_authenticity_token, :only => [:statusUpdate] # TODO: DONT FORGET TO FIX THIS

  before_action :authenticate_user! # TODO: AND THISSSSS
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  before_action :set_value_types, only: [:new, :edit]

  # GET /devices
  # GET /devices.json
  def index
    @devices = Device.select('uid, name, location').where(user_id: current_user.id).find_each
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
  end

  # GET /devices/new
  def new
    @device = Device.new
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device         = Device.new(safe_device_params)
    @device.user_id = current_user.id

    if params.require(:device).include?(:properties)
      params.require(:device).fetch(:properties).each do |key, new_property|
        @device.properties.build(safe_device_property_params(new_property))
      end
    end

    respond_to do |format|
      if @device.save
        # Now its time to save the properties
        format.html {redirect_to @device, notice: 'Device was successfully created.'}
        format.json {render :show, status: :created, location: @device}
      else
        set_value_types
        format.html {render :new}
        format.json {render json: @device.errors, status: :unprocessable_entity}
      end
    end

  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    stored_device_property_ids = @device.properties.ids

    posted_device_property_ids = []
    device_property_post       = nil
    if params.require(:device).include?(:properties)
      device_property_post = params.require(:device).fetch(:properties)
      device_property_post.each do |key, property|
        if !property[:id].empty?
          posted_device_property_ids << property[:id].to_i
        else
          @device.properties.build(safe_device_property_params(property))
        end
      end
    end

    # and compute which of them we need to delete
    device_property_ids_to_delete = stored_device_property_ids - posted_device_property_ids

    # puts "STORED: #{stored_device_property_ids}"
    # puts "POSTED: #{posted_device_property_ids}"
    # puts "TO DELETE: #{device_property_ids_to_delete}"

    # First delete the deleted ones
    if device_property_ids_to_delete
      Property.destroy(device_property_ids_to_delete)
    end

    # second loop exists, in order to not make multiple select queries
    # this code block is for update existing properties
    if !posted_device_property_ids.empty? # This mean, that someone make an update request where there are remaining property ids
      if !@device.properties.empty? # It's a double-check that device some device properties exists on DB
        @device.properties.each do |stored_property|
          device_property_post.each do |key, posted_property|
            if stored_property[:id].to_i == posted_property[:id].to_i
              stored_property.attributes = safe_device_property_params(posted_property)
            end
          end
        end
      end
    end

    respond_to do |format|
      if @device.update(safe_device_params)
        format.html {redirect_to @device, notice: 'Device was successfully updated.'}
        format.json {render :show, status: :ok, location: @device}
      else
        set_value_types
        format.html {render :edit}
        format.json {render json: @device.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    # first we need to delete all properties
    if !@device.properties.empty?
      @device.properties.each do |device_property|
        device_property.destroy
      end
    end

    # then delete the schedules
    if !@device.schedules.empty?
      @device.schedules.each do |device_schedule|
        device_schedule.destroy
      end
    end

    # finally destroy the device
    @device.destroy

    respond_to do |format|
      format.html {redirect_to devices_url, notice: 'Device was successfully destroyed.'}
      format.json {head :no_content}
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

  ##############################################################################
  ##### PRIVATE METHODS ########################################################
  ##############################################################################

  # Use callbacks to share common setup or constraints between actions.
  private def set_device
    @device = Device.where(user_id: current_user.id).find(params[:uid])
  end

  private def set_value_types
    @value_types = []
    ValueType.all.each do |value|
      @value_types << [value.name, value.id]
    end
    if @value_types.empty?
      redirect_to admin_path
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private def safe_device_params
    params.require(:device).permit(:name, :location, :description)
  end

  private def safe_device_property_params(unsafe_property)
    unsafe_property.permit(:name, :auto, :property_type_id, :value_type_id, :value_min, :value_max, :value)
  end

end
