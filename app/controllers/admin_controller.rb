class AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    @value_types = ValueType.all
  end

end
