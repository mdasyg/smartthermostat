class QuickButtonAction < ApplicationRecord

  belongs_to :quick_button
  belongs_to :action, dependent: :destroy

end