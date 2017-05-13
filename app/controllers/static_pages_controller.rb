class StaticPagesController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:test]


  def home
  end

  def test

    puts("sdfsdf")



    render json: request.inspect
  end

end
