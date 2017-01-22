class DevicePropertyAttribute
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :auto, Integer
  attribute :property_type_id, Integer
  attribute :value_type_id, Integer
  attribute :value_min, String
  attribute :value_max, String
  attribute :property_value, String
end

class DeviceForm
  include ActiveModel::Model
  include Virtus.model

  attribute :uid, Integer
  attribute :name, String
  attribute :location, String
  attribute :description, String
  attribute :access_token, String
  attribute :last_contact_at, DateTime

  attribute :properties, Array[DevicePropertyAttribute]

  # :properties => DevicePropertyAttribute

end