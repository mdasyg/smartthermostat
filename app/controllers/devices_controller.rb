class DevicesController < ApplicationController
  # skip_before_action :verify_authenticity_token, :only => [:statusUpdate] # TODO: DONT FORGET TO FIX THIS

  before_action :authenticate_user! # TODO: AND THISSSSS
  before_action :set_device, only: [:show, :edit, :update, :destroy, :get_device_attributes_list]
  before_action :set_value_types, only: [:new, :edit]

  # GET /devices
  # GET /devices.json
  def index
    @devices = Device.select('uid, name, location').where(user_id: current_user.id).find_each
  end

  # GET /devices/1/get_device_attributes_list
  def get_device_attributes_list
    render json: @device.device_attributes
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

    if params.require(:device).include?(:attributes)
      params.require(:device).fetch(:attributes).each do |key, new_attribute|
        @device.device_attributes.build(safe_device_attribute_params(new_attribute))
      end
    end

    respond_to do |format|
      if @device.save
        # Now its time to save the device attributes
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
    stored_device_attribute_ids = @device.device_attributes.ids

    posted_device_attribute_ids = []
    device_attribute_post       = nil
    if params.require(:device).include?(:attributes)
      device_attribute_post = params.require(:device).fetch(:attributes)
      device_attribute_post.each do |key, device_attribute|
        if !device_attribute[:id].empty?
          posted_device_attribute_ids << device_attribute[:id].to_i
        else
          @device.device_attributes.build(safe_device_attribute_params(device_attribute))
        end
      end
    end

    # and compute which of them we need to delete
    device_attribute_ids_to_delete = stored_device_attribute_ids - posted_device_attribute_ids

    # puts "STORED: #{stored_device_attribute_ids}"
    # puts "POSTED: #{posted_device_attribute_ids}"
    # puts "TO DELETE: #{device_attribute_ids_to_delete}"

    # First delete the deleted ones
    if device_attribute_ids_to_delete
      DeviceAttribute.destroy(device_attribute_ids_to_delete)
    end

    # second loop exists, in order to not make multiple select queries
    # this code block is for update existing device attributes
    if !posted_device_attribute_ids.empty? # This mean, that someone made an update request, where there are some device attributes
      if !@device.device_attributes.empty? # It's a double-check that the device has device device attributes on DB
        @device.device_attributes.each do |stored_device_attribute|
          device_attribute_post.each do |key, posted_device_attribute|
            if stored_device_attribute[:id].to_i == posted_device_attribute[:id].to_i
              stored_device_attribute.attributes = safe_device_attribute_params(posted_device_attribute)
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
    # first we need to delete all device attributes
    if !@device.device_attributes.empty?
      @device.device_attributes.each do |device_attribute|
        device_attribute.destroy
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

  private def safe_device_attribute_params(unsafe_attribute)
    unsafe_attribute.permit(:name, :value_type_id, :value_min, :value_max, :set_value)
  end

end
