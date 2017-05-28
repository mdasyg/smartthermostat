class DevicePropertyAttribute
  include ActiveModel::Model
  include Virtus.model

  RECORD_NEW = :new
  RECORD_EXISTING = :existing

  attribute :id, Integer
  attribute :device_uid, Integer
  attribute :name, String
  attribute :auto, Integer
  attribute :property_type_id, Integer
  attribute :value_type_id, Integer
  attribute :value_min, String
  attribute :value_max, String
  attribute :property_value, String
  attribute :record_state, String

  # def initialize(attributes = {})
  #   @id = attributes[:id]
  #   @device_id = attributes[:device_id]
  #   @name = attributes[:name]
  #   @auto = attributes[:auto]
  #   @property_type_id = attributes[:property_type_id]
  #   @value_type_id = attributes[:value_type_id]
  #   @value_min = attributes[:value_min]
  #   @value_max = attributes[:value_max]
  #   @property_value = attributes[:property_value]
  # end

end

class DeviceForm
  include ActiveModel::Model
  include Virtus.model

  attribute :uid, Integer
  attribute :user_id, Integer
  attribute :name, String
  attribute :location, String
  attribute :description, String
  attribute :access_token, String
  attribute :last_contact_at, DateTime

  attribute :properties, Array[DevicePropertyAttribute] # maybe a hash better?

  # def initialize(attributes)
  #   @uid = attributes.has_attribute?(:uid) ? attributes.uid : nil
  #   @user_id = attributes.has_attribute?(:user_id) ? attributes.user_id : nil
  #   @name = attributes.has_attribute?(:name) ? attributes.name : nil
  #   @location = attributes.has_attribute?(:location) ? attributes.location : nil
  #   @description = attributes.has_attribute?(:description) ? attributes.description : nil
  #   if attributes.properties != nil
  #     attributes.properties.each do |set_prop|
  #       @properties = DevicePropertyAttribute.new(set_prop)
  #     end
  #   end
  # end

end
