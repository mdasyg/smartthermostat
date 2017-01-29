class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  before_action :set_device_form_template, only: [:new, :edit]
  # before_action :set_device_form, only: [ :edit ]

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

    @device = Device.new
    @device.device_properties.build
    @prop_types = PropertyType.all
    @value_types = ValueType.all

    # @device_form = DeviceForm.new
    # @device_form.properties = DevicePropertyAttribute.new(record_state: DevicePropertyAttribute::RECORD_NEW )

  end

  # GET /devices/1/edit
  def edit

    @prop_types = PropertyType.all
    @value_types = ValueType.all

  end

  # POST /devices
  # POST /devices.json
  def create

    # clear out the params
    secure_params = device_params

    # and after that pass the values to the ActiveRecord models
    @device = Device.new(
        name: secure_params[:name],
        location: secure_params[:location],
        description: secure_params[:description],
    )
    @device.user_id = current_user.id

    respond_to do |format|
      if @device.save

        # Now its time to save the properties
        secure_params[:new_properties].each do |new_prop|
          @device.device_properties.create(new_prop)
        end

        # and then respond to request
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

    # CHECKLATER: check if we need some validations on existing ids.

    # clear out the params
    secure_params = device_params

    # get the stored properties
    stored_device_property_ids = @device.device_properties.ids

    # found the existings from post
    existing_device_properties = secure_params.has_key?(:existing_properties) ? secure_params[:existing_properties] : nil
    existing_device_property_ids = []
    if existing_device_properties
      existing_device_properties
          .keys
          .each { |index| existing_device_property_ids << index.to_i }
    end

    # and compute which of them we need to delete
    device_property_ids_to_delete = stored_device_property_ids - existing_device_property_ids

    respond_to do |format|
      if @device.update(
          name: secure_params[:name],
          location: secure_params[:location],
          description: secure_params[:description],
      )

        # First delete the deleted ones
        # TODO: find a clever way to include some filtering to not let someone delete others properties
        if device_property_ids_to_delete
          DeviceProperty.destroy(device_property_ids_to_delete)
        end

        # Then update the remaining existing if one
        @device.device_properties.update(existing_device_properties.keys, existing_device_properties.values) if existing_device_properties

        # Now its time to save the new properties
        # TODO: make it better
        if secure_params[:new_properties]
          secure_params[:new_properties].each do |new_prop|
            @device.device_properties.create(new_prop)
          end
        end

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
    # first we need to delete all properties
    if !@device.device_properties.empty?
      @device.device_properties.each do |device_property|
        device_property.destroy
      end
    end

    # finally destroy the device
    @device.destroy

    respond_to do |format|
      format.html { redirect_to devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Set a new DeviceForm object for use in the device-property-template in "NEW" and "EDIT" actions
  def set_device_form_template
    @device_form_template = Device.new
    @device_form_template.device_properties.build
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_device
    @device = Device
                  .where( user_id: current_user.id )
                  .find(params[:uid])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def device_params
    params
        .require(:device)
        .permit(
            :name, :location, :description,
            new_properties: [
                                :name, :auto,
                                :property_type_id, :value_type_id,
                                :value_min, :value_max,
                                :property_value,
                            ],
            existing_properties: [
                                :name, :auto,
                                :property_type_id, :value_type_id,
                                :value_min, :value_max,
                                :property_value,
                            ],
        )
  end

  # def set_device_form
  #   @device = Device
  #                 .select( 'uid, name, location, description' )
  #                 .where( user_id: current_user.id )
  #                 .find(params[:uid])
  #   @device_form = DeviceForm.new(@device)
  #   @device_form.properties = DevicePropertyAttribute.new(@device.device_properties)
  # end

end
