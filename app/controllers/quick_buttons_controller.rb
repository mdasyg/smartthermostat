class QuickButtonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quick_button, only: [:show, :edit, :update, :destroy]

  # GET /quick_buttons
  # GET /quick_buttons.json
  def index
    @quick_buttons = current_user.quick_buttons.all
  end

  # GET /quick_buttons/1
  # GET /quick_buttons/1.json
  def show
  end

  # GET /quick_buttons/new
  def new
    @quick_button = QuickButton.new
  end

  # GET /quick_buttons/1/edit
  def edit
  end

  # POST /quick_buttons
  # POST /quick_buttons.json
  def create
    @quick_button         = QuickButton.new(quick_button_params)
    @quick_button.user_id = current_user.id

    if !params.include?(:quick_button_event)
      @quick_button.errors.add(:quick_button_event, 'Please select a device')
      respond_to do |format|
        format.html {render :new}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end and return
    end

    if !params.require(:quick_button_event).include?(:actions)
      @quick_button.errors.add(:quick_button_event, 'At least one action must exists')
      respond_to do |format|
        format.html {render :new}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end and return
    end

    params[:quick_button_event][:actions].each do |key, action|
      @quick_button.actions.build(safe_quick_button_action_params(action))
    end

    respond_to do |format|
      if @quick_button.save
        format.html {redirect_to @quick_button, notice: 'Quick button was successfully created.'}
        format.json {render :show, status: :created, location: @quick_button}
        format.json {
          full_quick_button = render_to_string partial: 'quick_button/quick_button', locals: { quick_button: @quick_button }
          render json: { data: JSON::parse(full_quick_button), result: :ok }
        }
      else
        format.html {render :new}
        format.json {
          full_quick_button = render_to_string partial: 'quick_button/quick_button', locals: { quick_button: @quick_button }
          render json: { data: JSON::parse(full_quick_button), result: :ok }
        }
      end
    end

    # Send MQTT update to the corresponding device
    mqtt_send_quick_button_data()

  end

  # PATCH/PUT /quick_buttons/1
  # PATCH/PUT /quick_buttons/1.json
  def update

    if !params.include?(:quick_button_event)
      @quick_button.errors.add(:quick_button_event, 'Please select a device')
      respond_to do |format|
        format.html {render :edit}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end and return
    end

    if !params.require(:quick_button_event).include?(:actions)
      @quick_button.errors.add(:quick_button_event, 'At least one action must exists')
      respond_to do |format|
        format.html {render :edit}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end and return
    end

    old_device_uid           = @quick_button.device_uid
    old_index_on_device      = @quick_button.index_on_device
    @quick_button.attributes = quick_button_params

    if old_device_uid != @quick_button.device_uid
      @quick_button.errors.add(:device_uid, 'Cannot be changed')
      respond_to do |format|
        format.html {render :edit}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end and return
    end

    quick_button_event_actions_post = params[:quick_button_event][:actions]
    @quick_button.actions.each do |stored_quick_button_action|
      quick_button_event_actions_post.each do |key, posted_quick_button_action|
        if !posted_quick_button_action[:id].empty? && (posted_quick_button_action[:id].to_i == stored_quick_button_action.id)
          stored_quick_button_action.attributes = safe_quick_button_action_params(posted_quick_button_action)
        end
      end
    end

    begin
      @quick_button.transaction do
        if @quick_button.save
          respond_to do |format|
            format.html {redirect_to @quick_button, notice: 'Quick button was successfully updated.'}
            format.json {render json: { result: :ok }}
          end
          # Now must send update to device from MQTT
          if old_index_on_device != @quick_button.index_on_device
            mqtt_destroy_quick_button(@quick_button.device_uid, old_index_on_device)
          end
          mqtt_send_quick_button_data()
        else
          respond_to do |format|
            format.html {render :edit}
            format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
          end
        end
      end
    rescue Exception => e
      @quick_button.errors.add(:base, 'Cannot update')
      respond_to do |format|
        format.html {render :edit}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end
    end

  end

  # DELETE /quick_buttons/1
  # DELETE /quick_buttons/1.json
  def destroy
    begin
      device_uid      = @quick_button.device_uid
      index_on_device = @quick_button.index_on_device
      @quick_button.transaction do
        action_ids = @quick_button.actions.ids
        @quick_button.quick_button_actions.destroy
        @quick_button.destroy
        Action.destroy(action_ids)
        respond_to do |format|
          format.html {redirect_to quick_buttons_url, notice: 'Quick Button was successfully destroyed.'}
          format.json {render json: { result: :ok }}
        end
        # Send update to device from MQTT
        mqtt_destroy_quick_button(device_uid, index_on_device)
      end
    rescue Exception => e
      puts e.message
      respond_to do |format|
        format.html {redirect_to quick_buttons_url, notice: 'Error when destroying Quick Button.'}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end
    end

  end

  ##############################################################################
  # Use callbacks to share common setup or constraints between actions.
  ##############################################################################
  private def set_quick_button
    @quick_button = current_user.quick_buttons.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private def quick_button_params
    params.require(:quick_button).permit(:device_uid, :index_on_device, :title, :description, :duration)
  end

  private def safe_quick_button_action_params(unsafe_action)
    unsafe_action.permit(:device_attribute_id, :device_attribute_start_value, :device_attribute_end_value)
  end

  private def mqtt_send_quick_button_data
    mqtt_client      = MQTT::Client.new()
    mqtt_client.host = Rails.application.secrets.mqtt[:host]
    mqtt_client.port = Rails.application.secrets.mqtt[:port]

    # mqtt_client.on_connect do |rc|
    #   puts "Connected with return code #{rc}"
    # end

    payload = ActiveSupport::JSON.encode({ qb: { idx: @quick_button.index_on_device, id: @quick_button.id, dur: @quick_button.duration } })
    mqtt_client.connect()
    mqtt_client.publish(@quick_button.device_uid.to_s, payload, false, 0)
    @quick_button.actions.each do |quick_button_action|
      payload = ActiveSupport::JSON.encode({ qb_a: { idx: @quick_button.index_on_device, da_idx: quick_button_action.device_attribute.index_on_device, start: quick_button_action.device_attribute_start_value, end: quick_button_action.device_attribute_end_value } })
      mqtt_client.connect()
      mqtt_client.publish(@quick_button.device_uid.to_s, payload, false, 0)
    end
    mqtt_client.disconnect()
  end

  private def mqtt_destroy_quick_button(device_uid, index)
    mqtt_client      = MQTT::Client.new()
    mqtt_client.host = Rails.application.secrets.mqtt[:host]
    mqtt_client.port = Rails.application.secrets.mqtt[:port]

    # mqtt_client.on_connect do |rc|
    #   puts "Connected with return code #{rc}"
    # end

    payload = ActiveSupport::JSON.encode({ qb_del: { idx: index.to_s } })
    mqtt_client.connect()
    mqtt_client.publish(device_uid.to_s, payload, false, 0)
    mqtt_client.disconnect()
  end

end
