class QuickButton < ApplicationRecord

  validates :title, presence: true
  validates :index_on_device, presence: true
  validates :duration, presence: true

  belongs_to :user, inverse_of: :quick_buttons
  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :quick_buttons

  has_many :quick_button_actions
  has_many :actions, through: :quick_button_actions, dependent: :destroy, autosave: true

end
