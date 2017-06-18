class DeviceAttribute < ApplicationRecord

  validates :name, presence: true

  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device_attributes
  belongs_to :value_type, inverse_of: :device_attributes
  has_many :actions, inverse_of: :device_attribute

end
