class AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    set_primitive_types
    @value_types = ValueType.all
  end

  def manage_value_types

    models_has_errors = false

    @value_types = []

    if params.include?(:value_types)
      params.fetch(:value_types).each do |key, valueType|
        if valueType[:id].empty?
          # this is a new entry
          new_value_type = ValueType.new(safe_value_type_params(valueType))
          if new_value_type.invalid?
            models_has_errors = true
          end
          new_value_type.save
          @value_types << new_value_type
        else
          # this is an old entry so update
          old_value_type            = ValueType.find(valueType[:id])
          old_value_type.attributes = safe_value_type_params(valueType)
          if old_value_type.invalid?
            models_has_errors = true
          end
          old_value_type.save
          @value_types << old_value_type
        end
      end
    end

    respond_to do |format|
      if !models_has_errors
        format.html {redirect_to admin_url, notice: 'Value Types was successfully updated.'}
        # format.json {render :show, status: :created, location: @device}
      else
        set_primitive_types
        format.html {render :index}
        # format.json {render json: @device.errors, status: :unprocessable_entity}
      end
    end

  end

  ##############################################################################
  ##### PRIVATE METHODS ########################################################
  ##############################################################################

  private def set_primitive_types
    @primitive_types = []
    ValueType::PRIMITIVE_TYPES.each do |key, p_type|
      @primitive_types << [p_type[:LABEL], p_type[:ID]]
    end
  end

  private def safe_value_type_params(unsafe_value_type)
    unsafe_value_type.permit(:name, :primitive_type_id, :unsigned)
  end

end
