class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  before_action :set_available_devices, only: [:new, :edit]
  before_action :set_repeat_every_list, only: [:new, :edit]

  # GET /schedules
  # GET /schedules.json
  def index
    @schedules = Schedule.select('*').where(user_id: current_user.id).find_each
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
  end

  # GET /schedules/new
  def new
    if @availiable_devices.empty?
      redirect_to new_device_path
    end
    @schedule = Schedule.new
    set_selected_device_properties
  end

  # GET /schedules/1/edit
  def edit
    set_selected_device_properties
  end

  # POST /schedules
  # POST /schedules.json
  def create

    event = Event.new

    @schedule         = event.build_schedule(safe_schedule_params)
    @schedule.user_id = current_user.id

    if !params.include?(:actions)
      @schedule.errors[:base] << "Actions must exists"
      respond_to do |format|
        set_available_devices
        set_repeat_every_list
        set_selected_device_properties
        format.html {render :new}
        format.json {render json: @schedule.errors, status: :unprocessable_entity}
      end
      return
    end
    #
    # @schedule.build_event()
    # @schedule.valid?
    # @schedule.event.valid?

    params[:actions].each do |key, action|
      @schedule.event.actions.build(action.permit(:property_id, :property_value)).valid?
    end

    respond_to do |format|
      if event.save
        format.html {redirect_to @schedule, notice: 'Schedule was successfully created.'}
        format.json {render :show, status: :created, location: @schedule}
      else
      set_available_devices
      set_repeat_every_list
      set_selected_device_properties
      format.html {render :new}
      format.json {render json: @schedule.errors, status: :unprocessable_entity}
      end
    end

  end

  # PATCH/PUT /schedules/1
  # PATCH/PUT /schedules/1.json
  def update
    respond_to do |format|
      if @schedule.update(safe_schedule_params)
        format.html {redirect_to @schedule, notice: 'Schedule was successfully updated.'}
        format.json {render :show, status: :ok, location: @schedule}
      else
        set_available_devices
        set_repeat_every_list
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

  private def set_available_devices
    devices             = current_user.devices
    @availiable_devices = []
    if !devices.empty?
      devices.each do |device|
        @availiable_devices << [device.name, device.uid]
      end
    end
  end

  private def set_selected_device_properties
    @selected_device_properties = []
    if @schedule.device_uid
      @schedule.device.properties.each do |property|
        @selected_device_properties << [property.name, property.id]
      end
    end
  end

  private def set_repeat_every_list
    @repeat_every_list = []
    Schedule::REPAT_EVERY.each do |key, value|
      @repeat_every_list << [value[:LABEL], value[:ID]]
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  private def safe_schedule_params
    params.require(:schedule).permit(:device_uid, :datetime, :is_recurrent, :repeat_every, :recurrence_period)
  end
end
