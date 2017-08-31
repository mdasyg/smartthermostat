class QuickButtonsController < ApplicationController
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

    if !params.require(:quick_button_event).include?(:actions)
      @quick_button.errors.add(:schedule_events, 'At least one action must exists')
      respond_to do |format|
        format.html {render :new}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end
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
  end

  # PATCH/PUT /quick_buttons/1
  # PATCH/PUT /quick_buttons/1.json
  def update
    if !params.require(:quick_button_event).include?(:actions)
      @quick_button.errors.add(:base, 'At least one action must exists')
      respond_to do |format|
        format.html {render :edit}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end
    end

    @quick_button.attributes = quick_button_params

    quick_button_event_action_ids_to_be_deleted = []
    quick_button_event_actions_post             = params[:quick_button_event][:actions]
    @quick_button.actions.each do |stored_quick_button_action|
      puts stored_quick_button_action.inspect
      puts stored_quick_button_action.id
      stored_action_found = false
      quick_button_event_actions_post.each do |key, posted_quick_button_action|
        if !posted_quick_button_action[:id].empty?&& (posted_quick_button_action[:id].to_i == stored_quick_button_action.id)
          stored_action_found                   = true
          stored_quick_button_action.attributes = safe_quick_button_action_params(posted_quick_button_action)
        end
      end
      if stored_action_found == false
        quick_button_event_action_ids_to_be_deleted << stored_quick_button_action.id
      end
    end

    quick_button_event_actions_post.each do |key, posted_quick_button_action|
      if posted_quick_button_action[:id].empty?
        @quick_button.actions.build(safe_quick_button_action_params(posted_quick_button_action))
      end
    end

    puts 'To be deleted'
    puts quick_button_event_action_ids_to_be_deleted

    begin
      @quick_button.transaction do
        @quick_button.actions.destroy(quick_button_event_action_ids_to_be_deleted)
        @quick_button.save
        respond_to do |format|
          format.html {redirect_to @quick_button, notice: 'Quick button was successfully updated.'}
          format.json {render json: { result: :ok }}
        end
      end
    rescue
      respond_to do |format|
        format.html {render :edit}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end
    end

    # respond_to do |format|
    #   if @quick_button.update(quick_button_params)
    #     format.html {redirect_to @quick_button, notice: 'Quick button was successfully updated.'}
    #     format.json {render :show, status: :ok, location: @quick_button}
    #   else
    #     format.html {render :edit}
    #     format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
    #   end
    # end

    # if action[:id]
    #   if stored_action_ids.include?(action[:id].to_i)
    #     stored_quick_button_action = @quick_button.actions.find_by_id(action[:id])
    #     if stored_quick_button_action
    #       stored_quick_button_action.attributes = safe_quick_button_action_params(action)
    #     else
    #       @quick_button.errors.add(:base, 'Action does not exists')
    #       respond_to do |format|
    #         format.html {render :edit}
    #         format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
    #       end
    #     end
    #   end
    # else
    #   @quick_button.actions.build(safe_quick_button_action_params(action))
    # end
  end

  # DELETE /quick_buttons/1
  # DELETE /quick_buttons/1.json
  def destroy
    begin
      @quick_button.transaction do
        action_ids = @quick_button.actions.ids
        Action.destroy(action_ids)
        @quick_button.destroy
        respond_to do |format|
          format.html {redirect_to quick_buttons_url, notice: 'Quick Button was successfully destroyed.'}
          format.json {render json: { result: :ok }}
        end
      end
    rescue
      respond_to do |format|
        format.html {redirect_to quick_buttons_url, notice: 'Error when destroying Quick Button.'}
        format.json {render json: { messages: @quick_button.errors.full_messages, result: :error }}
      end
    end
  end

  ##############################################################################
  # Use callbacks to share common setup or constraints between actions.
  ##############################################################################
  # Use callbacks to share common setup or constraints between actions.
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
end
