class QuickButtonsController < ApplicationController
  before_action :set_quick_button, only: [:show, :edit, :update, :destroy]

  # GET /quick_buttons
  # GET /quick_buttons.json
  def index
    @quick_buttons = QuickButton.all
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
    @quick_button = QuickButton.new(quick_button_params)

    respond_to do |format|
      if @quick_button.save
        format.html { redirect_to @quick_button, notice: 'Quick button was successfully created.' }
        format.json { render :show, status: :created, location: @quick_button }
      else
        format.html { render :new }
        format.json { render json: @quick_button.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quick_buttons/1
  # PATCH/PUT /quick_buttons/1.json
  def update
    respond_to do |format|
      if @quick_button.update(quick_button_params)
        format.html { redirect_to @quick_button, notice: 'Quick button was successfully updated.' }
        format.json { render :show, status: :ok, location: @quick_button }
      else
        format.html { render :edit }
        format.json { render json: @quick_button.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quick_buttons/1
  # DELETE /quick_buttons/1.json
  def destroy
    @quick_button.destroy
    respond_to do |format|
      format.html { redirect_to quick_buttons_url, notice: 'Quick button was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quick_button
      @quick_button = QuickButton.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quick_button_params
      params.require(:quick_button).permit(:user_id, :device_uid, :index_on_device, :title, :description, :duration)
    end
end
