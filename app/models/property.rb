class Property < ApplicationRecord

  validates :name, presence: true

  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :properties
  belongs_to :value_type, inverse_of: :properties
  has_many :actions, inverse_of: :Property

end
