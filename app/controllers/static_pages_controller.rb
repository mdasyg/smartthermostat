class StaticPagesController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:test]


  def home
  end

  def test

    puts("/" + params.except(:controller, :action).keys.to_s + "/")

    render json: params.except(:controller, :action).keys.to_s
  end

end
