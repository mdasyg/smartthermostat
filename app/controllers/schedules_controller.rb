class SchedulesController < ApplicationController

  include DevicesHelper

  before_action :authenticate_user!
  before_action :set_schedule, only: [:show, :edit, :update, :destroy, :get_overlapping_schedules]
  before_action :set_schedule_recurrent_unit_list, only: [:new, :edit, :index]

  # GET /schedules
  # GET /schedules.json
  def index
    query_string = 'is_recurrent = :is_recurrent'
    query_params = {
        is_recurrent: '0'
    }

    if params.include?(:start)
      if !query_string.empty?
        query_string += ' AND '
      end
      query_string                  += 'start_datetime >= :start_datetime'
      query_params[:start_datetime] = params[:start]
    end

    if params.include?(:end)
      if !query_string.empty?
        query_string += ' AND '
      end
      query_string                += 'end_datetime <= :end_datetime'
      query_params[:end_datetime] = params[:end]
    end

    @schedules = current_user.schedules.select('*').where([query_string, query_params]).find_each

    if params.include?(:start)
      start_time = Time.zone.iso8601(params[:start])
    else
      return
    end

    if params.include?(:end)
      end_time = Time.zone.iso8601(params[:end])
    else
      return
    end

    recurrent_schedules = current_user.schedules.select('*').where(['is_recurrent = :is_recurrent', { is_recurrent: '1' }])

    @recurrent_schedules_array = []
    recurrent_schedules.find_each do |schedule|
      if schedule.start_datetime >= start_time
        start_time_loop = schedule.start_datetime
      else
        start_time_loop = start_time
        start_time_loop = start_time_loop.change(hour: schedule.start_datetime.hour, minutes: schedule.start_datetime.min, seconds: schedule.start_datetime.sec)
      end

      frequency = nil
      if schedule.recurrence_unit == Schedule::REPEAT_EVERY[:DAY][:ID]
        frequency = schedule.recurrence_frequency.day.to_i
      elsif schedule.recurrence_unit == Schedule::REPEAT_EVERY[:WEEK][:ID]
        frequency = schedule.recurrence_frequency.week.to_i
      else
        return 'Recurrence unit not exists.'
      end

      puts "Freq: #{frequency}"

      while start_time_loop <= end_time do
        puts "Time to check: #{start_time_loop} against: #{schedule.start_datetime}"

        diff = start_time_loop - schedule.start_datetime
        puts "Diff: #{diff}"

        if (diff == 0)
          puts "BINGO"
          schedule.original_schedule = 1 # TRUE
          @recurrent_schedules_array << schedule
        elsif (diff != 0)
          if (diff % frequency) == 0
            puts "BINGO"
            puts "Time executing: #{(diff / frequency).to_i}"
            new_schedule                   = schedule.dup
            new_schedule.id                = schedule.id
            new_schedule.original_schedule = 0 # FALSE
            new_schedule.start_datetime    = start_time_loop
            new_schedule.end_datetime      = new_schedule.start_datetime + (schedule.end_datetime - schedule.start_datetime)
            @recurrent_schedules_array << new_schedule
          end
        end
        puts ''

        start_time_loop = start_time_loop.advance(days: 1)
      end
    end

    puts @recurrent_schedules_array.inspect

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

    # maybe add this to model validations
    if (@schedule.end_datetime <= @schedule.start_datetime)
      @schedule.errors[:end_datetime] << 'Must be bigger than start datetime'
      respond_to do |format|
        format.html {set_schedule_recurrent_unit_list(); render :new}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    if !params.include?(:schedule_events)
      @schedule.errors[:base] << 'At least one event must exists'
      respond_to do |format|
        format.html {set_schedule_recurrent_unit_list(); render :new}
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
        format.html {set_schedule_recurrent_unit_list(); render :new}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    overlapping_schedules = check_schedule_overlaps(@schedule)
    if @schedule.errors.any?
      respond_to do |format|
        format.json {render json: { messages: @schedule.errors.full_messages, overlaps: overlapping_schedules, result: :error }}
      end and return
    end

    respond_to do |format|
      if @schedule.save # this will also save the schedule and event actions
        format.html {redirect_to @schedule, notice: 'Schedule was successfully created.'}
        format.json {
          full_schedule = render_to_string partial: 'schedules/schedule', locals: { schedule: @schedule }
          render json: { data: JSON::parse(full_schedule), result: :ok }
        }

        mqtt_client      = MQTT::Client.new()
        mqtt_client.host = Rails.application.secrets.mqtt[:host]
        mqtt_client.port = Rails.application.secrets.mqtt[:port]
        mqtt_client.connect()

        @schedule.schedule_events.each do |schedule_event|
          send_new_schedule_table_to_device(schedule_event.device, mqtt_client)
        end

        mqtt_client.disconnect()

      else
        format.html {set_schedule_recurrent_unit_list(); render :new}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end
    end

  end

  # PATCH/PUT /schedules/1
  # PATCH/PUT /schedules/1.json
  def update
    old_schedule         = @schedule.dup
    @schedule.attributes = safe_schedule_params

    #  If schedule post is from a non original schedule(this has effect on recurrent schedules), dont permit date change, only time. For date change must update the original event.
    if params.require(:schedule).include?(:original_schedule)
      if params.require(:schedule).fetch(:original_schedule).empty?
        original_schedule = 1
      else
        original_schedule = params.require(:schedule).fetch(:original_schedule).to_i
      end
    end
    if original_schedule == 0
      @schedule.start_datetime = @schedule.start_datetime.change(year: old_schedule.start_datetime.year, month: old_schedule.start_datetime.month, day: old_schedule.start_datetime.day)
      @schedule.end_datetime   = @schedule.end_datetime.change(year: old_schedule.end_datetime.year, month: old_schedule.end_datetime.month, day: old_schedule.end_datetime.day)
    end

    # maybe add this to model validations
    if (@schedule.end_datetime <= @schedule.start_datetime)
      @schedule.errors[:end_datetime] << 'Must be bigger than start datetime'
      respond_to do |format|
        format.html {set_schedule_recurrent_unit_list(); render :edit}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    if !params.include?(:schedule_events)
      @schedule.errors[:base] << 'At least one event must exists'
      respond_to do |format|
        format.html {set_schedule_recurrent_unit_list(); render :edit}
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
        format.html {set_schedule_recurrent_unit_list(); render :edit}
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
        format.html {set_schedule_recurrent_unit_list(); render :edit}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end and return
    end

    overlapping_schedules = check_schedule_overlaps(@schedule)
    if @schedule.errors.any?
      respond_to do |format|
        format.json {render json: { messages: @schedule.errors.full_messages, overlaps: overlapping_schedules, result: :error }}
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
        respond_to do |format|
          if @schedule.save # this will also save the schedule and event actions
            format.html {redirect_to @schedule, notice: 'Schedule was successfully created.'}
            format.json {
              full_schedule = render_to_string partial: 'schedules/schedule', locals: { schedule: @schedule }
              render json: { data: JSON::parse(full_schedule), result: :ok }
            }

            mqtt_client      = MQTT::Client.new()
            mqtt_client.host = Rails.application.secrets.mqtt[:host]
            mqtt_client.port = Rails.application.secrets.mqtt[:port]
            mqtt_client.connect()

            @schedule.schedule_events.each do |schedule_event|
              send_new_schedule_table_to_device(schedule_event.device, mqtt_client)
            end

            mqtt_client.disconnect()

          else
            format.html {set_schedule_recurrent_unit_list(); render :edit}
            format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
          end
        end
      end
    rescue Exception => e
      if Rails.env.development?
        msg = [e.to_s]
      else
        msg = ['Please contact with admin']
      end
      respond_to do |format|
        format.html {set_schedule_recurrent_unit_list(); render :edit}
        format.json {render json: { messages: msg, result: :error }}
      end
    end

  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    begin
      @schedule.transaction do
        devices_to_update_schedule = []
        @schedule.schedule_events.each do |schedule_event|
          devices_to_update_schedule << schedule_event.device.dup
          action_ids = schedule_event.actions.ids
          schedule_event.destroy
          Action.destroy(action_ids)
        end
        @schedule.destroy

        mqtt_client      = MQTT::Client.new()
        mqtt_client.host = Rails.application.secrets.mqtt[:host]
        mqtt_client.port = Rails.application.secrets.mqtt[:port]
        mqtt_client.connect()

        devices_to_update_schedule.each do |device|
          send_new_schedule_table_to_device(device, mqtt_client)
        end

        mqtt_client.disconnect()

        respond_to do |format|
          format.html {redirect_to schedules_url, notice: 'Schedule was successfully destroyed.'}
          format.json {render json: { result: :ok }}
        end
      end
    rescue
      respond_to do |format|
        set_schedule_recurrent_unit_list()
        format.html {render :index}
        format.json {render json: { messages: @schedule.errors.full_messages, result: :error }}
      end
    end
  end

  def get_overlapping_schedules
    overlapping_schedules = check_schedule_overlaps(@schedule)
    respond_to do |format|
      if (overlapping_schedules.nil?)
        format.json {render json: { result: :ok }}
      else
        format.json {render json: { overlaps: overlapping_schedules, result: :error }}
      end
    end
  end

  def update_overlapping_schedules_priorities
    if !params.include?(:overlap_schedules)
      respond_to do |format|
        format.json {render json: { messages: 'No overlaps posted', result: :error }}
      end and return
    end

    params[:overlap_schedules].each do |index, overlap_schedule|
      if overlap_schedule[:priority].blank?
        next # cannot delete priority
      end
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

  private def check_schedule_overlaps(schedule)
    # recurrent schedules will automatically have the lowest priority and will
    # not be take into account in this phase
    if schedule.is_recurrent == true
      return nil
    end

    query_string = ''
    query_string += 'schedules.end_datetime >= :start_datetime'
    query_string += ' AND '
    query_string += 'schedules.start_datetime <= :end_datetime'
    query_params = {
        start_datetime: schedule.start_datetime,
        end_datetime:   schedule.end_datetime,
    }

    number_of_schedule_events = schedule.schedule_events.size-1
    query_string              += ' AND ('
    schedule.schedule_events.each_with_index do |schedule_event, index|
      query_string += 'schedule_events.device_uid = :dev_uid_' + index.to_s
      if index < number_of_schedule_events
        query_string += ' OR '
      end
      query_params["dev_uid_#{index.to_s}".to_sym] = schedule_event.device_uid
    end
    query_string += ')'

    if (schedule.id)
      query_string               += ' AND '
      query_string               += 'schedules.id <> :schedule_id'
      query_params[:schedule_id] = schedule.id
    end

    overlapping_schedules = current_user.schedules.select(:'schedules.id', :'schedules.title', :'schedules.start_datetime', :'schedules.end_datetime', :'schedules.priority').joins(:schedule_events).where([query_string, query_params]).find_each
    if !overlapping_schedules.any?
      return nil
    end

    priorities = overlapping_schedules.pluck(:priority)
    priorities << @schedule.priority

    if !priorities.index(nil).nil? # This means that nil does exists on array
      @schedule.errors[:base] << 'Not all priorities has been set'
    end

    if priorities.uniq != priorities
      @schedule.errors[:base] << 'Duplicate priorities'
    end

    return overlapping_schedules
  end

  private def set_schedule_recurrent_unit_list
    @schedule_recurrent_unit_list = []
    Schedule::REPEAT_EVERY.each do |key, value|
      @schedule_recurrent_unit_list << [value[:LABEL], value[:ID]]
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private def safe_schedule_params
    params.require(:schedule).permit(:title, :description, :start_datetime, :end_datetime, :is_recurrent, :recurrence_frequency, :recurrence_unit, :priority)
  end

  private def safe_schedule_event_params(unsafe_schedule_event)
    unsafe_schedule_event.permit(:device_uid)
  end

  private def safe_schedule_action_params(unsafe_action)
    unsafe_action.permit(:device_attribute_id, :device_attribute_start_value, :device_attribute_end_value)
  end
end
