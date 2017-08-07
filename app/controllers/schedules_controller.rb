class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: [:show, :edit, :update, :destroy, :get_overlapping_schedules]
  before_action :set_repeat_every_list, only: [:new, :edit, :index]

  # GET /schedules
  # GET /schedules.json
  def index

    # TODO: FIX IT

    # if params.include?(:start)
    #   if params.include?(:end)
    #     @schedules = current_user.schedules.select('*').where(['start_datetime >= :start_datetime AND end_datetime <= :end_datetime', { start_datetime: params[:start], end_datetime: params[:end] }]).find_each
    #   else
    #     @schedules = current_user.schedules.select('*').where(['start_datetime >= :start_datetime', { start_datetime: params[:start] }]).find_each
    #   end
    # else
    #   @schedules = current_user.schedules.find_each
    # end

    @schedules = current_user.schedules.find_each

    @schedule = Schedule.new # it's for the modal
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

    if !schedules_overlaps_ok?(@schedule.start_datetime, @schedule.end_datetime)
      return false
    end

    # maybe add this to model validations
    if (@schedule.end_datetime <= @schedule.start_datetime)
      @schedule.errors[:end_datetime] << 'Must be bigger than start datetime'
      respond_to do |format|
        format.html {set_repeat_every_list(); render :new}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    if !params.include?(:schedule_events)
      @schedule.errors[:base] << 'At least one event must exists'
      respond_to do |format|
        set_repeat_every_list()
        format.html {render :new}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    errors_exists = false
    params[:schedule_events].each do |key, schedule_event|
      current_schedule_event = @schedule.schedule_events.build(safe_schedule_event_params(schedule_event))
      if !schedule_event.include?(:actions)
        errors_exists = true
        @schedule.errors.add(:schedule_events, 'At least one action must exists')
        current_schedule_event.errors.add(:base, 'At least one action must exists')
      else
        schedule_event[:actions].each do |key, action|
          current_schedule_event.actions.build(safe_schedule_action_params(action))
        end
      end
    end

    if errors_exists
      respond_to do |format|
        format.html {set_repeat_every_list(); render :new}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    respond_to do |format|
      if @schedule.save # this will also save the schedule and event actions
        format.html {redirect_to @schedule, notice: 'Schedule was successfully created.'}
        format.json {
          full_schedule = render_to_string partial: 'schedules/schedule', locals: { schedule: @schedule }
          render json: { data: JSON::parse(full_schedule), result: :ok }
        }
      else
        format.html {set_repeat_every_list(); render :new}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end
    end

  end

  # PATCH/PUT /schedules/1
  # PATCH/PUT /schedules/1.json
  def update
    @schedule.attributes = safe_schedule_params

    if !schedules_overlaps_ok?(@schedule.start_datetime, @schedule.end_datetime)
      return false
    end

    if !params.include?(:schedule_events)
      @schedule.errors[:base] << 'At least one event must exists'
      respond_to do |format|
        format.html {set_repeat_every_list(); render :edit}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    stored_schedule_events_ids = @schedule.schedule_events.ids

    posted_schedule_events_ids = []
    schedule_events_post       = params[:schedule_events]
    errors_exists              = false
    schedule_events_post.each do |key, schedule_event|
      if schedule_event[:id].empty?
        current_schedule_event = @schedule.schedule_events.build(safe_schedule_event_params(schedule_event))
        if !schedule_event.include?(:actions)
          errors_exists = true
          @schedule.errors.add(:schedule_events, 'At least one action must exists')
          current_schedule_event.errors.add(:base, 'At least one action must exists')
        else
          schedule_event[:actions].each do |key, action|
            current_schedule_event.actions.build(safe_schedule_action_params(action))
          end
        end
      else
        posted_schedule_events_ids << schedule_event[:id].to_i
      end
    end

    if errors_exists
      respond_to do |format|
        format.html {set_repeat_every_list(); render :edit}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    schedule_events_ids_to_delete = stored_schedule_events_ids - posted_schedule_events_ids

    # Update the existing objects
    errors_exists = false
    if !posted_schedule_events_ids.empty? # This mean, that someone made an update request, where there are some stored schedule events on it
      @schedule.schedule_events.each do |stored_schedule_event|
        schedule_events_post.each do |key, posted_shcedule_event|
          if !stored_schedule_event[:id].nil? && (stored_schedule_event[:id].to_i == posted_shcedule_event[:id].to_i)
            # stored_schedule_event.attributes = safe_schedule_event_params(posted_shcedule_event)
            if !posted_shcedule_event.include?(:actions)
              errors_exists = true
              @schedule.errors.add(:schedule_events, 'At least one action must exists')
              stored_schedule_event.errors.add(:base, 'At least one action must exists')
            else
              stored_schedule_event.actions.each do |stored_action|
                posted_shcedule_event[:actions].each do |key, posted_action|
                  if stored_action[:id].to_i == posted_action[:id].to_i
                    stored_action.attributes = safe_schedule_action_params(posted_action)
                  end
                end
              end
            end
          end
        end
      end
    end

    if errors_exists
      respond_to do |format|
        format.html {set_repeat_every_list(); render :edit}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    begin
      @schedule.transaction do
        # First delete the deleted ones
        if schedule_events_ids_to_delete
          schedule_events_ids_to_delete.each do |se_id|
            schedule_event = ScheduleEvent.find(se_id)
            action_ids     = schedule_event.actions.ids
            schedule_event.destroy
            Action.destroy(action_ids)
          end
        end
        @schedule.save
        respond_to do |format|
          format.html {redirect_to @schedule, notice: 'Schedule was successfully updated.'}
          format.json {
            full_schedule = render_to_string partial: 'schedules/schedule', locals: { schedule: @schedule }
            render json: { data: JSON::parse(full_schedule), result: :ok }
          }
        end
      end
    rescue
      respond_to do |format|
        format.html {set_repeat_every_list(); render :edit}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end
    end

  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    begin
      @schedule.transaction do
        @schedule.schedule_events.each do |se|
          action_ids = se.actions.ids
          se.destroy
          Action.destroy(action_ids)
        end
        @schedule.destroy
        respond_to do |format|
          format.html {redirect_to schedules_url, notice: 'Schedule was successfully destroyed.'}
          format.json {render json: { result: :ok }}
        end
      end
    rescue
      respond_to do |format|
        set_repeat_every_list()
        format.html {render :index}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end
    end
  end

  def get_overlapping_schedules
    overlaps = schedules_overlaps_ok?(@schedule.start_datetime, @schedule.end_datetime)
    if overlaps
      if (overlaps == true)
        respond_to do |format|
          format.json {render json: { result: :ok }}
        end
      else
        respond_to do |format|
          format.json {render json: { overlaps: overlaps, result: :ok }}
        end
      end
    end
  end

  def update_overlapping_schedules_priorities
    if !params.include?(:overlap_schedules)
      respond_to do |format|
        format.json {render json: { messages: 'No overlaps', result: :error }}
      end and return
    end

    params[:overlap_schedules].each do |index, overlap_schedule|
      schedule = current_user.schedules.where(['id = :schedule_id', { schedule_id: overlap_schedule[:id] }]).take
      if !schedule.nil?
        schedule.priority = overlap_schedule[:priority]
        if !schedule.save
          respond_to do |format|
            format.json {render json: { messages: schedule.errors, result: :error }}
          end and return
        end
      end
    end

    respond_to do |format|
      format.json {render json: { result: :ok }}
    end

  end

  ##############################################################################
  # Use callbacks to share common setup or constraints between actions.
  ##############################################################################
  private def set_schedule
    @schedule = current_user.schedules.find(params[:id])
  end

  private def schedules_overlaps_ok?(start_datetime, end_datetime)
    query_string = ''
    query_string += 'end_datetime >= :start_datetime'
    query_string += ' AND '
    query_string += 'start_datetime <= :end_datetime'

    query_params = {
        start_datetime: start_datetime,
        end_datetime:   end_datetime,
    }

    if (@schedule.id)
      query_string += ' AND '
      query_string += 'id <> :schedule_id'

      query_params[:schedule_id] = @schedule.id
    end

    overlapping_schedules = current_user.schedules.select('*').where([query_string, query_params]).find_each
    if !overlapping_schedules.any?
      return true
    end

    priorities = overlapping_schedules.pluck(:priority)
    priorities << @schedule.priority

    if !priorities.index(nil).nil? # This means that nil does exists on array
      @schedule.errors[:base] << 'Not all priorities has been set'
      respond_to do |format|
        format.json {render json: { messages: @schedule.errors.full_messages, overlaps: overlapping_schedules, result: :error }}
      end and return false
    end

    if priorities.uniq != priorities
      @schedule.errors[:base] << 'Duplicate priorities'
      respond_to do |format|
        format.json {render json: { messages: @schedule.errors.full_messages, overlaps: overlapping_schedules, result: :error }}
      end and return false
    end

    return overlapping_schedules
  end

  private def set_repeat_every_list
    @repeat_every_list = []
    Schedule::REPEAT_EVERY.each do |key, value|
      @repeat_every_list << [value[:LABEL], value[:ID]]
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private def safe_schedule_params
    params.require(:schedule).permit(:title, :description, :start_datetime, :end_datetime, :is_recurrent, :repeat_every, :recurrence_period, :priority)
  end

  private def safe_schedule_event_params(unsafe_schedule_event)
    unsafe_schedule_event.permit(:device_uid)
  end

  private def safe_schedule_action_params(unsafe_action)
    unsafe_action.permit(:device_attribute_id, :device_attribute_start_value, :device_attribute_end_value)
  end
end
