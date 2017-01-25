class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  before_action :set_device_form_template, only: [:new, :edit]

  # GET /devices
  # GET /devices.json
  def index
    @devices = Device
                   .select( 'uid, name, location' )
                   .where( user_id: current_user.id )
                   .find_each
  end

  # GET /devices/1
  # GET /devices/1.json
  def show
  end

  # GET /devices/new
  def new
    @device_form = DeviceForm.new
    @device_form.properties = DevicePropertyAttribute.new(record_state: DevicePropertyAttribute::RECORD_NEW )

    # @device = Device.new
    # @device.device_properties.build
    @prop_types = PropertyType.select( 'id, name' ).find_each
    @value_types = ValueType.select( 'id, name' ).find_each
  end

  # GET /devices/1/edit
  def edit
  end

  # POST /devices
  # POST /devices.json
  def create
    @device = Device.new(device_params)
    @device.user_id = current_user.id
abort
    respond_to do |format|
      if @device.save

        format.html { redirect_to @device, notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devices/1
  # PATCH/PUT /devices/1.json
  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to @device, notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devices/1
  # DELETE /devices/1.json
  def destroy
    @device.destroy
    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Set a new DeviceForm object for use in the device-property-template in "NEW" and "EDIT" actions
    def set_device_form_template
      @device_form_template = DeviceForm.new
      @device_form_template.properties = DevicePropertyAttribute.new(record_state: DevicePropertyAttribute::RECORD_NEW )
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device
                    .where( user_id: current_user.id )
                    .find(params[:uid])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device_form).permit(:name, :location, :description)
    end
end
