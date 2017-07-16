class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  before_action :set_repeat_every_list, only: [:new, :edit, :index]

  # GET /schedules
  # GET /schedules.json
  def index
    if params.include?(:start)
      if params.include?(:end)
        @schedules = Schedule.select('*').where(['user_id = :user_id AND start_datetime >= :start_datetime AND end_datetime <= :end_datetime', { user_id: current_user.id, start_datetime: params[:start], end_datetime: params[:end] }]).find_each
      else
        @schedules = Schedule.select('*').where(['user_id = :user_id AND start_datetime >= :start_datetime', { user_id: current_user.id, start_datetime: params[:start] }]).find_each
      end
    else
      @schedules = Schedule.select('*').where(user_id: current_user.id).find_each
    end
    @schedule = Schedule.new
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
  end

  # GET /schedules/new
  def new
    @schedule = Schedule.new
  end

  # GET /schedules/1/edit
  def edit
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule         = Schedule.new(safe_schedule_params)
    @schedule.user_id = current_user.id

    puts @schedule.schedule_events.inspect

    if !params.include?(:schedule_events)
      @schedule.errors[:base] << 'At least one event must exists'
      respond_to do |format|
        set_repeat_every_list()
        format.html {render :new}
        format.json {render json: @schedule.errors, status: :unprocessable_entity}
      end
      return
    end

    errors_exists = false
    params[:schedule_events].each do |key, schedule_event|
      puts key.inspect
      puts schedule_event.inspect
      current_schedule_event = @schedule.schedule_events.build(safe_schedule_event_params(schedule_event))
      if !schedule_event.include?(:actions)
        errors_exists = true
        @schedule.errors.add(:schedule_events, 'At least one action must exists')
        current_schedule_event.errors.add(:base, 'At least one action must exists')
      else
        schedule_event[:actions].each do |key, action|
          puts key
          puts action.inspect
          current_schedule_event.actions.build(safe_schedule_action_params(action))
        end
      end
    end

    if errors_exists
      respond_to do |format|
        set_repeat_every_list()
        format.html {render :new}
        format.json {render json: @schedule.errors, status: :unprocessable_entity}
      end and return
    end

    respond_to do |format|
      if @schedule.save # this will also save the schedule and event actions
        format.html {redirect_to @schedule, notice: 'Schedule was successfully created.'}
        format.json {render :show, status: :created, location: @schedule}
      else
        set_repeat_every_list
        format.html {render :new}
        format.json {render json: @schedule.errors, status: :unprocessable_entity}
      end
    end

  end

  # PATCH/PUT /schedules/1
  # PATCH/PUT /schedules/1.json
  def update
    if !params.include?(:actions)
      @schedule.errors[:base] << 'At least one action must exist'
      respond_to do |format|
        set_available_devices
        set_repeat_every_list
        set_selected_device_attributes
        format.html {render :edit}
        format.json {render json: @schedule.errors, status: :unprocessable_entity}
      end
      return
    end

    stored_schedule_actions_ids = @schedule.actions.ids

    posted_schedule_actions_ids = []
    schedule_actions_post       = params[:actions]
    schedule_actions_post.each do |key, action|
      if action[:id].empty?
        @schedule.actions.build(safe_schedule_action_params(action))
      else
        posted_schedule_actions_ids << action[:id].to_i
      end
    end

    # schedule action ids to delete
    schedule_action_ids_to_delete = stored_schedule_actions_ids - posted_schedule_actions_ids

    # puts "STORED: #{stored_schedule_actions_ids}"
    # puts "POSTED: #{posted_schedule_actions_ids}"
    # puts "TO DELETE: #{schedule_action_ids_to_delete}"

    # UPdate the existing objects
    if !posted_schedule_actions_ids.empty? # This mean, that someone made an update request, where there are some actions on it
      if @schedule.actions.any? # It's a double-check that the schedule has actions on DB
        @schedule.actions.each do |stored_action|
          schedule_actions_post.each do |key, posted_action|
            if stored_action[:id].to_i == posted_action[:id].to_i
              stored_action.attributes = safe_schedule_action_params(posted_action)
            end
          end
        end
      end
    end

    begin
      @schedule.transaction do
        # # First delete the deleted ones
        # if schedule_action_ids_to_delete
        #   Action.destroy(schedule_action_ids_to_delete)
        # end
        schedule_action_ids_to_delete.each do |action_id|
          @schedule.actions.find(action_id).destroy!
        end
        @schedule.update!(safe_schedule_params)
        respond_to do |format|
          format.html {redirect_to @schedule, notice: 'Schedule was successfully updated.'}
          format.json {render :show, status: :ok, location: @schedule}
        end
      end
    rescue
      respond_to do |format|
        set_available_devices
        set_repeat_every_list
        set_selected_device_attributes
        format.html {render :edit}
        format.json {render json: @schedule.errors, status: :unprocessable_entity}
      end
    end

  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    @schedule.destroy
    respond_to do |format|
      format.html {redirect_to schedules_url, notice: 'Schedule was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  private def set_repeat_every_list
    @repeat_every_list = []
    Schedule::REPEAT_EVERY.each do |key, value|
      @repeat_every_list << [value[:LABEL], value[:ID]]
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private def safe_schedule_params
    params.require(:schedule).permit(:title, :description, :start_datetime, :end_datetime, :is_recurrent, :repeat_every, :recurrence_period)
  end

  private def safe_schedule_event_params(unsafe_schedule_event)
    unsafe_schedule_event.permit(:device_uid)
  end

  private def safe_schedule_action_params(unsafe_action)
    unsafe_action.permit(:device_attribute_id, :device_attribute_start_value, :device_attribute_end_value)
  end
end
