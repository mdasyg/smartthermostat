class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: [:show, :edit, :update, :destroy, :get_device_attributes_list]
  before_action :set_primitive_types, only: [:new, :edit]
  before_action :set_directions, only: [:new, :edit]

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

    if params.require(:device).include?(:attributes)
      params.require(:device).fetch(:attributes).each do |key, new_attribute|
        @device.device_attributes.build(safe_device_attribute_params(new_attribute))
      end
    end

    respond_to do |format|
      if @device.save
        # Now its time to save the device attributes
        format.html {redirect_to @device, notice: 'Device was successfully created.'}
        format.json {
          full_device = render_to_string partial: 'devices/device', locals: { schedule: @device }
          render json: { data: JSON::parse(full_device), result: :ok }
        }
      else
        format.html {set_primitive_types(); set_directions(); render :new}
        format.json {render json: { messages: @device.errors.full_messages, result: :error }}
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
        format.json {
          full_device = render_to_string partial: 'devices/device', locals: { schedule: @device }
          render json: { data: JSON::parse(full_device), result: :ok }
        }
      else
        format.html {set_primitive_types(); set_directions(); render :edit}
        format.json {render json: { messages: @device.errors.full_messages, result: :error }}
      end
    end
  end

  def update_device_attribute_value
    device_attribute = DeviceAttribute.joins(:device).where("devices.user_id = #{current_user.id}", device_uid: params[:device_uid]).find_by(id: params[:pk])

    puts device_attribute.inspect

    if (device_attribute.nil?)
      render json: { status: :error, msg: ['Device Attribute not exist'] }, status: :not_found
    end

    device_attribute.write_attribute(params[:name], params[:value])

    puts device_attribute.inspect

    if device_attribute.save
      render(json: { status: :ok, msg: ['Attribute updated successfully'] })

      mqtt_client = Mosquitto::Client.new('tasos-test')
      # puts mqtt_client.inspect

      mqtt_client.on_connect {|rc|
        p "Connected with return code #{rc}"
        # publish a test message once connected
        # mqtt_client.publish(nil, device_uid, 'test message', Mosquitto::AT_MOST_ONCE, true)
      }

      mqtt_client.connect('home-auto.eu', 1883, 10)

      payload = ActiveSupport::JSON.encode({ da: { id: device_attribute.id, set: device_attribute.read_attribute(params[:name]) } })
      mqtt_client.publish(nil, params[:device_uid], payload, Mosquitto::AT_MOST_ONCE, false)

      mqtt_client.disconnect()

    else
      render json: { status: :error, msg: device_attribute.errors }, status: :internal_server_error
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

  def search
    if !params.has_key?(:term)
      render json: [] and return
    else
      search_term = params[:term]
    end

    results = Device.select('uid, name').where(['name LIKE :name', { name: '%' + search_term + '%' }])

    formatted_results = []
    results.each do |device|
      formatted_results << { id: device.uid.to_s, text: device.name }
    end

    render json: formatted_results

  end

  # GET /devices/1/get_device_attributes_list
  def get_device_attributes_list
    render json: @device.device_attributes
  end

  ##############################################################################
  ##### PRIVATE METHODS ########################################################
  ##############################################################################

  # Use callbacks to share common setup or constraints between actions.
  private def set_device
    @device = Device.where(user_id: current_user.id).find(params[:uid])
  end

  private def set_primitive_types
    @primitive_types = []
    DeviceAttribute::PRIMITIVE_TYPES.each do |key, p_type|
      @primitive_types << [p_type[:LABEL], p_type[:ID]]
    end
  end

  private def set_directions
    @directions = []
    DeviceAttribute::DIRECTIONS.each do |key, direction|
      @directions << [direction[:LABEL], direction[:ID]]
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private def safe_device_params
    params.require(:device).permit(:name, :location, :description)
  end

  private def safe_device_attribute_params(unsafe_attribute)
    unsafe_attribute.permit(:name, :primitive_type_c_id, :direction_c_id, :unit, :min_value, :max_value, :set_value)
  end

end
