class DeviceInfo < ApplicationRecord

  belongs_to :device, foreign_key: :device_uid, primary_key: :uid, inverse_of: :device_infos

end
