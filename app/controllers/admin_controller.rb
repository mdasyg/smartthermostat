class AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    @value_types = ValueType.all
  end

  def updateValueTypes


    puts 'HIII'


    respond_to do |format|
      format.html {redirect_to admin_url, notice: 'Value Types was successfully updated.'}
      # format.json {render :show, status: :created, location: @device}
    end
  end

end
